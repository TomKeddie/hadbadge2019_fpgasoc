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
 * along with this software.  If not, see <https://www.gnu.org/licenses/>.
 */
#include <stdint.h>
#include <stdio.h>
#include <cstdlib>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "psram_emu.hpp"

Psram_emu::Psram_emu(int memsize) {
	m_size=memsize;
	m_mem=new uint8_t[memsize];
	m_roflag=new uint8_t[memsize]();
	for (int i=0; i<m_size; i++) m_mem[i]=rand();
	m_qpi_mode=0;
}

const uint8_t *Psram_emu::get_mem() {
	return m_mem;
}

void Psram_emu::force_qpi() {
	m_qpi_mode=1;
}

int Psram_emu::load_file(const char *file, int offset, bool is_ro) {
	FILE *f=fopen(file, "rb");
	if (f==NULL) {
		perror(file);
		exit(1);
	}
	int size=fread(&m_mem[offset], 1, m_size-offset, f);
	fclose(f);
	if (is_ro) {
		for (int i=offset; i<offset+size; i++) m_roflag[i]=1;
	}
	printf("Loaded file %s to 0x%X - 0x%X\n", file, offset, offset+size);
	return 0;
}

int Psram_emu::load_file_nibbles(const char *file, int offset, bool is_ro, bool msb_nibble) {
	FILE *f=fopen(file, "rb");
	if (f==NULL) {
		perror(file);
		exit(1);
	}
	fseek(f, 0, SEEK_END);
	long fsize=ftell(f);
	fseek(f, 0, SEEK_SET);
	uint8_t *buf=(uint8_t*)malloc(fsize);
	fread(buf, 1, fsize, f);
	fclose(f);
	for (int i=0; i<fsize; i+=2) {
		if (msb_nibble) {
			m_mem[(offset+i)/2]=((buf[i]>>4)<<4)+(buf[i+1]>>4);
		} else {
			m_mem[(offset+i)/2]=((buf[i]&0xf)<<4)+(buf[i+1]&0xf);
		}
	}
	if (is_ro) {
		for (int i=offset/2; i<(offset+fsize)/2; i++) m_roflag[i]=1;
	}
	free(buf);
	printf("Loaded file %s to 0x%X - 0x%X\n", file, offset, offset+(fsize/2));
	return 0;
}



int Psram_emu::eval(int clk, int ncs, int sin, int oe, int *sout) {
	if (ncs==1) {
		m_nib=0;
		m_cmd=0;
		m_addr=0;
	} else if (m_oldclk==clk) {
		//nothing
	} else if (clk) {
		//posedge clk
		if (!m_qpi_mode) {
			//Just inited: SPI mode. nib is used as byte ctr
			if (m_nib<8) {
				m_cmd<<=1;
				if (sin&1) m_cmd|=1;
				m_nib++;
				if (m_nib==8) {
					if (m_cmd==0x35) {
						m_qpi_mode=1;
						printf("psram: switched to qpi mode\n");
					} else {
						printf("psram: Unknown command in SPI mode: 0x%02X\n", m_cmd);
					}
				}
			}
		} else {
			sin&=0xf;
			if (m_nib==0) m_cmd|=(sin<<4);
			if (m_nib==1) m_cmd|=(sin);
			if (m_nib==1 && (m_cmd!=0xeb && m_cmd!=0x02 && m_cmd!=0x38)) {
				printf("psram: Unsupported QPI command: 0x%02X\n", m_cmd);
			}
			if (m_nib==2) m_addr|=(sin<<20);
			if (m_nib==3) m_addr|=(sin<<16);
			if (m_nib==4) m_addr|=(sin<<12);
			if (m_nib==5) m_addr|=(sin<<8);
			if (m_nib==6) m_addr|=(sin<<4);
			if (m_nib==7) {
				m_addr|=(sin);
//				printf("cmd %x addr %x\n", m_cmd, m_addr);
			}
			if (m_nib>=8 && (m_cmd==0x2 || m_cmd==0x38)) {
				//write of data
				if ((m_nib&1)==0) {
					m_writebyte=(sin<<4);
				} else {
					m_writebyte|=sin;
					if (m_mem[m_addr]!=m_writebyte && m_roflag[m_addr]) {
						printf("ERROR! Overwriting ro-marked data at addr 0x%X (which is 0x%02X) with 0x%02X!\n", m_addr, m_mem[m_addr], m_writebyte);
						return 1;
					}
					if (m_addr>=m_size) {
						printf("ERROR! Write past size of device at addr 0x%X!\n", m_addr);
						return 1;
					}
					m_mem[m_addr]=m_writebyte;
					m_addr++;
				}
			}

			if (m_nib>=13 && m_cmd==0xeb) {
				if (m_addr>=m_size) {
					printf("ERROR! Read past size of device at addr 0x%X!\n", m_addr);
					return 1;
				}
				if (m_nib&1) {
					m_sout_next=m_mem[m_addr]>>4;
				} else {
//					printf("Psram read at %x: %x\n", m_addr, m_mem[m_addr]);
					m_sout_next=m_mem[m_addr++]&0xf;
				}
			}
			m_nib++;
		}
	} else {
		//negedge clk
		m_sout_cur=m_sout_next;
	}
	m_oldclk=clk;
	*sout=ncs?0:m_sout_next;
	return 0;
}

