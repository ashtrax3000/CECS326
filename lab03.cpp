#include <iostream>
#include <unistd.h>
#include <cstdlib>
#include <sys/wait.h>
using namespace std;

int main(){
	pid_t child01, child02, child03, child04;

	// ====	BEGIN OF CHILD 01 ==============

	child01 = fork();

	if (child01 < 0) {
		cout << "Error: Fork failed" << endl;
		exit (1);
	}

	else if (child01 == 0) {
		//execlp("/bin/ls", "ls", "-l", NULL);

				  // ====	BEGIN OF CHILD 02 ==============

					child02 = fork();

					if (child02 < 0) {
						cout << "Error: Fork failed" << endl;
						exit (1);
					}

					else if (child02 == 0)
						execlp("/bin/ls", "ls", "-l", NULL);

					else {
						cout << "CHILD1: about fork and show a long list of directory contents: \"ls ‐l\"" << endl;
						wait( &child02 );

						// ====	BEGIN OF CHILD 03 ==============

						child03 = fork();

						if (child03 < 0) {
							cout << "Error: Fork failed" << endl;
							exit (1);
						}

						else if (child03 == 0)
							execlp("/bin/cat", "cat", "hello.cpp", NULL);

						else {
							cout << "CHILD1: about fork and show hello.cpp contents:" << endl;
							wait( &child03 );
							cout << "   child03 Done :)" << endl;


							// ====	BEGIN OF CHILD 04 ==============

							child04 = fork();

							if (child04 < 0) {
								cout << "Error: Fork failed" << endl;
								exit (1);
							}

							else if (child04 == 0) {
								//cout << "   child04 executing \"g++ hello.cpp ‐o hello.out\"" << endl;
								execlp("/bin/gcc", "gcc", "hello.cpp", "-o", "hello.out");
							}

							else {
								cout << "CHILD1: about fork and compile hello.cpp:" << endl;
								wait( &child04 );
								//cout << "   child01 executing \"./hello.out 2\"" << endl;
								execlp("/bin/sh","./hello.out", "4", NULL);


							}
							// ====	END OF CHILD 04 ==============

						}
						// ====	END OF CHILD 03 ==============

					}
					// ====	END OF CHILD 02 ==============
	}

	else {
		cout << "PARENT: waiting for my child to exit" <<  endl;
		wait( &child01 );
		cout << "PARENT: Child finally exited :)" << endl;
	}

	// ====	END OF CHILD 01 ==============
	exit( 0 );
}
