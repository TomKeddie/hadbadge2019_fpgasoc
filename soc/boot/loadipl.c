/*
 * Copyright 2019 Jeroen Domburg <jeroen@spritesmods.com>
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
 */
#include "gloss/mach_defines.h"
#include <stdint.h>
#include <stdbool.h>
#include "ipl_flash.h"


typedef void (*fun_ptr_t)(void);

typedef struct {
	uint32_t magic;
	uint32_t size;
	uint32_t entry_point;
	uint32_t data[];
} ipl_t;

#define IPL_FLASH_LOC 0x300000
#define IPL_CART_FLASH_LOC 0x180000
#define IPL_MAGIC 0x1337b33f

extern uint32_t cart_boot_flag;

void load_ipl() {
	ipl_t *ipl=(ipl_t*)MEM_IPL_START;
	flash_wake(FLASH_SEL_CURRENT);
	uint64_t curr_uid=flash_get_uid(FLASH_SEL_CURRENT);
	flash_wake(FLASH_SEL_CART);
	uint64_t cart_uid=flash_get_uid(FLASH_SEL_CART);
	
	if (curr_uid==cart_uid ) {
		cart_boot_flag=1;
		//We booted from the cartridge. See if there's a viable IPL there, if so load it.
		flash_read(FLASH_SEL_CART, IPL_CART_FLASH_LOC, (uint8_t*)ipl, sizeof(ipl_t));
		if (ipl->magic == IPL_MAGIC) {
			flash_read(FLASH_SEL_CART, IPL_CART_FLASH_LOC, (uint8_t*)ipl, ipl->size);
			return;
		}
	}
	//No cart boot or no valid IPL on cart. Load IPL from internal memory.
	flash_wake(FLASH_SEL_INT);
	flash_read(FLASH_SEL_INT, IPL_FLASH_LOC, (uint8_t*)ipl, sizeof(ipl_t));
	if (ipl->magic != IPL_MAGIC) return;
	flash_read(FLASH_SEL_INT, IPL_FLASH_LOC, (uint8_t*)ipl, ipl->size);
}

void run_ipl() {
	ipl_t *ipl=(ipl_t*)MEM_IPL_START;
	if (ipl->magic != IPL_MAGIC) return;
	fun_ptr_t entrypoint=(fun_ptr_t)&ipl->entry_point;
	entrypoint();
}

