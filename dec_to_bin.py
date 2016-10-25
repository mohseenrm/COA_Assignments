data = 0.00000000000000182750915653085671238567389596582716940583731
print( 'data : {0}'.format( data ) )
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