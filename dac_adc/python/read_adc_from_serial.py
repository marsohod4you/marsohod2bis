
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import serial

NUM_SAMPLES_HORZ = 256

def read_serial_port( port, num_values ):
	arr = []
	i=0
	in_read_buffer=serial_port.in_waiting
	if in_read_buffer>num_values :
		port.read( in_read_buffer-num_values )
	data = port.read( num_values )
	while i< num_values :
		arr.append( int(data[i]) )
		i = i+1
	return arr

# configure the serial connections
serial_port = serial.Serial(
	port='COM18',
	baudrate=12000000,
	parity=serial.PARITY_EVEN,
	stopbits=serial.STOPBITS_ONE,
	bytesize=serial.EIGHTBITS
)

serial_port.isOpen()

x = np.arange(0, NUM_SAMPLES_HORZ, 1)
y = read_serial_port( serial_port, NUM_SAMPLES_HORZ )

plt.ion()
ax = plt.gca()
ax.set(xlabel='samples', ylabel='value', title='Samples from ADC of Marsohod2bis FPGA board')
line, = ax.plot(x, y)

while 1:
	y = read_serial_port( serial_port, NUM_SAMPLES_HORZ )
	line.set_ydata( y )
	ax.relim()
	plt.draw()
	plt.pause(0.2)
	
	
