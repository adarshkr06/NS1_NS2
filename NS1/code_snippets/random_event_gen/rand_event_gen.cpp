#include <iostream>
#include <cstdlib>
#include <map>
#include <fstream>
#include <cstring>
#include <stdlib.h>
#include <time.h>
using namespace std;

const int MAX_CHARS_PER_LINE = 512;
const int MAX_TOKENS_PER_LINE = 20;
const char* const DELIMITER = "\t";

map<int,string> as_routerid;

int main()
{
  // create a file-reading object
  ifstream fin1;
  ifstream fin2;
  ifstream fin;
  ofstream fout;
  int rand_num;
  int sim_time = 100;
  fin1.open("as_numbers.info"); // open a file
  fin2.open("router_ids.info"); // open a file
  fout.open("ns.tcl", ios::app); // open a file
  // read each line of the file
  while (!fin1.eof())
  {
    // read an entire line into memory
    char buf1[MAX_CHARS_PER_LINE];
    fin1.getline(buf1, MAX_CHARS_PER_LINE);
    
    char buf2[MAX_CHARS_PER_LINE];
    fin2.getline(buf2, MAX_CHARS_PER_LINE);
    
    // array to store memory addresses of the tokens in buf
    const char* token1[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    const char* token2[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    
    // parse the line
    token1[0] = strtok(buf1, DELIMITER); // first token
    token2[0] = strtok(buf2, DELIMITER); // first token
    
    if (token1[0]) // zero if line is blank
    {
	as_routerid[atoi(token1[0])] = token2[0];	
    }

  }
   fin1.close();
   fin2.close();
   cout << "ROUTER ID OF 1 : " << as_routerid[1] << endl;
   cout << "ROUTER ID OF 701 : " << as_routerid[701] << endl;
   cout << "ROUTER ID OF 3561 : " << as_routerid[3561] << endl;
   cout << "ROUTER ID OF 6113 : " << as_routerid[6113] << endl;

  /* initialize random seed: */
  srand (time(NULL));

  for (int i=0; i < 1000; i++)
  {
  	/* generate secret number between 1 and 10: */
  	rand_num = rand() % 10000;
	cout  << "THE RANDOM NUMBER GENERATED : " << rand_num << endl;
  	fin.open("router.info");
	while(!fin.eof())
	{
		char buf[30];
		fin.getline(buf, 30);
		int n = 0;
		const char* token[5] = {};
		token[0] = strtok(buf,"\t");
		if (token[0])
		{
			for (n = 1; n < 5; n++)
			{
				token[n] = strtok(0,"\t");
     				if (!token[n]) break;
			}
		}
		if (token[0])
		{
		//cout << "Value 1 : " << token[0] << " Value 2 : " << token[1] << endl;
		if ((atoi(token[0]) == rand_num) || (rand_num == atoi(token[1])))
		{
			cout << "AS NUMBER : " << token[0] << "\tNEIGHBOR : " << token[1] << "\t NEIGHBOR ROUTER-ID : " << as_routerid[atoi(token[1])] << endl;
			if (rand_num % 2)
			{
				fout << "$ns at " << sim_time << " \"$BGP" << token[0] << " command \\\"neighbor " << as_routerid[atoi(token[1])] << " shutdown \\\"\"" << endl;  
				sim_time = sim_time + 100;
				fout << "$ns at " << sim_time << " \"$BGP" << token[0] << " command \\\"no neighbor " << as_routerid[atoi(token[1])] << " shutdown \\\"\"" << endl;  
				sim_time = sim_time + 100;
				break;
			} else 
			{
				fout << "$ns at " << sim_time << " \"$BGP" << token[0] << " command \\\"route-map RMAP_NONCUST_OUT permit 10\\\"\"" << endl;  
				fout << "$ns at " << sim_time << " \"$BGP" << token[0] << " command \\\"clear ip bgp * soft\\\"\"" << endl;  
				sim_time = sim_time + 100;
				fout << "$ns at " << sim_time << " \"$BGP" << token[0] << " command \\\"route-map RMAP_NONCUST_OUT deny 10\\\"\"" << endl;  
				fout << "$ns at " << sim_time << " \"$BGP" << token[0] << " command \\\"clear ip bgp * soft\\\"\"" << endl;  
				sim_time = sim_time + 100;
				break;
			}
		}
		}
	}
	fin.close();
	
  }
   fout << "puts \"Starting the run\"" << endl;
   fout << "$ns run" << endl;
   fout << "set etime [clock seconds]" << endl;
   fout << "puts \"simulation elapsed seconds [expr $etime - $ltime]\"" << endl;
   fout.close();

}
