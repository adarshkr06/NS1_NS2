#include <iostream>
#include <stdlib.h>
#include <time.h>
#include <fstream>
#include <cstdlib>
#include <cstring>

using namespace std;
int main()
{
  int rand_num;
  ifstream fin;
  ofstream fout;

  fout.open("link_failure_event.info");

  /* initialize random seed: */
  srand (time(NULL));

  for (int i=0; i < 1000; i++)
  {
  	/* generate secret number between 1 and 10: */
  	rand_num = rand() % 10000;
	cout  << "THE RANDOM NUMBER GENERATED : " << rand_num << endl;
  	fin.open("as_numbers.info");
	while(!fin.eof())
	{
		char buf[30];
		fin.getline(buf, 30);
		int n = 0;
		const char* token[5] = {};
		token[0] = strtok(buf," ");
		if (token[0])
		{
			for (n=1;n<5;n++)
			token[n] = strtok(0," ");
     			if (!token[n]) break;
		}
		if (token[0])
		if (atoi(token[1]) == rand_num)
		{
			fout << "bgp" << rand_num << ".conf" << endl;
			break;
		}
		if (token[0])
      		cout << "Token[0] : " << token[1] << endl;
	}
	fin.close();
	
  }
}
