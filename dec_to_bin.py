data = 0.0000000000000001827509156530856712385673895965827169405837361
bin = []
counts = 5
while( data != 1 ):
	data *= 2
	if( counts > 0 ):
		counts -= 1
		print( data )
	bin.append( int( data ) )
	if( data > 1 ):
		data -= 1

print( ''.join( str( num ) for num in bin ) )