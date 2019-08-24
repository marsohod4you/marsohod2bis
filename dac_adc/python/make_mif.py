#Create Memory Initialization Files for Signal Generator Project
#Signal shapes will be stored in FPGA in memory block tables

import math

def write_mif_header( f ):
	f.write("WIDTH = 8;\n")
	f.write("DEPTH = 64;\n")
	f.write("ADDRESS_RADIX = HEX;\n")
	f.write("DATA_RADIX = HEX;\n")
	f.write("CONTENT BEGIN\n")

def write_mif_end( f ):
	f.write("END\n")

#MEANDR signal	
out_file = open("meandr.mif", "w")
write_mif_header( out_file )
i=0
while i<64:
	value = 255 if i<32 else 0
	out_file.write( "{0:04X} : {1:02X};\n".format( i, value) )
	i=i+1
write_mif_end( out_file )
out_file.close()

#SAW1 signal	
out_file = open("saw1.mif", "w")
write_mif_header( out_file )
i=0
while i<64:
	value = int(i*255/63)
	out_file.write( "{0:04X} : {1:02X};\n".format( i, value) )
	i=i+1
write_mif_end( out_file )
out_file.close()

#SAW2 signal	
out_file = open("saw2.mif", "w")
write_mif_header( out_file )
i=0
while i<64:
	value = int(255-i*255/63)
	out_file.write( "{0:04X} : {1:02X};\n".format( i, value) )
	i=i+1
write_mif_end( out_file )
out_file.close()

#SAW3 signal	
out_file = open("saw3.mif", "w")
write_mif_header( out_file )
i=0
while i<64:
	value = int(i*255/31) if i<32 else int(255-(i-31)*255/32)
	out_file.write( "{0:04X} : {1:02X};\n".format( i, value) )
	i=i+1
write_mif_end( out_file )
out_file.close()

#sinus signal	
out_file = open("sin.mif", "w")
write_mif_header( out_file )
i=0
while i<64:
	value = int( (math.sin( math.pi*2*i/64 )+1)*127.5 )
	out_file.write( "{0:04X} : {1:02X};\n".format( i, value) )
	i=i+1
write_mif_end( out_file )
out_file.close()
