/*

Create a C++ program which will receive numerical values through the command line and perform some computations.  Your program will operate with the following restrictions:
program will accept between 3 and 10 numerical command line arguments
NOTE:  checking if an argument is actually a decimal quantity isn't needed
the argument values must be between -100 and +100
restriction 1 or 2 is violated then output an error message and terminate the program
The program you create will
Output a list of numbers received as a command line arguments
Calculate the following:
Arithmetic sum of the command line argument number values
Arithmetic average of the command line argument number values
Value range of the command line argument number values
Example program run and outputs are shown below:

Example 1, when no arguments are entered:

./a.out
no arguments entered, I'm done
Example 2, when less than 3 arguments are entered:

./a.out 1
Please enter more than 3 numerical arguments
Example 3, proper program run with output

./a.out 1 2 3 4 5 6 7
The numbers received are being buffered up as follows:
numbersArray[ 0 ] = 1
numbersArray[ 1 ] = 2
numbersArray[ 2 ] = 3
numbersArray[ 3 ] = 4
numbersArray[ 4 ] = 5
numbersArray[ 5 ] = 6
numbersArray[ 6 ] = 7
The sum is 28
The average is 4.0
The range is 6

*/

#include <iostream>
#include <stdlib.h>

using namespace std;

bool argsInRange(char **, int, int , int);
void showArgs (char **, int);
int getSum (char **, int);
int getMaxValue (char ** , int);
int getMinValue (char ** , int);

const int LOW = -100;
const int HIGH = 100;

int main(int argc, char ** argv) {

	int argCounter = argc - 1;

	if (argCounter == 0 )
		cout << "No arguments entered, I'm done: " << endl;

	else if ( argCounter < 3 )
		cout << "Please enter more than 3 numerical arguments." << endl;
    
  else if ( argCounter > 10 )
		cout << "Please enter less than 10 numerical arguments." << endl;

  else if ( argsInRange(argv, argc, LOW,HIGH) ) {
		showArgs (argv, argc);
		cout << "Sum is " << getSum(argv, argc) << endl;
		cout << "The average is " << ( getSum(argv, argc) + 0.0) / argCounter << endl;
		cout << "The range is " << getMaxValue(argv, argc) - getMinValue(argv, argc) << endl;
	}
  
	else
		cout << "Arguments are out of range. Range is [-100, 100]. Bye" << endl;

	return 0;
}

//
bool argsInRange(char ** argv, int argc, int low, int high) {
	for (int i = 1; i < argc; i++ ) {
		if ( atoi( argv[ i ]) < low || atoi( argv[ i ]) > high)
			return false;
	}
}

//
void showArgs (char ** argv, int argc) {
	for ( int i = 1; i < argc; i++ )
		cout << "numbersArray[ " << i - 1 << " ] = " << argv[ i ] << endl;
}

//
int getSum (char ** argv, int argc) {
	int sum  = 0;
	for( int i = 1; i < argc; i++ )
		sum = sum + atoi( argv[ i ] );
	return sum;
}

int getMaxValue (char ** argv, int argc) {
	int maxValue  = -100;
	for( int i = 1; i < argc; i++ ) {
		if (atoi( argv[ i ] ) > maxValue)
			maxValue =  atoi( argv[ i ] );
	}
	return maxValue;
}

int getMinValue (char ** argv, int argc) {
	int minValue  = 100;
	for( int i = 1; i < argc; i++ ) {
		if (atoi( argv[ i ] ) < minValue)
			minValue =  atoi( argv[ i ] );
	}
	return minValue;
}

//
