#include <iostream>
#include <fstream>
#include <cstring>
#include <cstdlib>

using namespace std;

const int MAX_CHARS_PER_LINE = 512;
const int MAX_TOKENS_PER_LINE = 20;
const char* const DELIMITER = "\t";

int main()
{
  // create a file-reading object
  ifstream fin1;
  ifstream fin2;
  ofstream fout;
  int count = 0;
  fin1.open("router.info"); // open a file
  fin2.open("filter.info"); 
  fout.open("1krouter.info");

  // read each line of the file
  while (!fin1.eof())
  {
    // read an entire line into memory
    char buf1[MAX_CHARS_PER_LINE];
    fin1.getline(buf1, MAX_CHARS_PER_LINE);
    
    char buf2[MAX_CHARS_PER_LINE];
    fin2.getline(buf2, MAX_CHARS_PER_LINE);

    // parse the line into blank-delimited tokens
    int n = 0; // a for-loop index
    
    // array to store memory addresses of the tokens in buf
    const char* token[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    const char* token1[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    
    // parse the line
    token[0] = strtok(buf1, DELIMITER); // first token
    if (token[0]) // zero if line is blank
    {
      for (n = 1; n < MAX_TOKENS_PER_LINE; n++)
      {
        token[n] = strtok(0, DELIMITER); // subsequent tokens
        if (!token[n]) break; // no more tokens
      }
    }
    token1[0] = strtok(buf2, DELIMITER);
    if (!token1[0])
	break;
    if (!atoi(token1[0]))    
    	fout << token[0] << "\t" << token[1] << "\t" << token[2] << endl;
    else
	{	
		count++;
		if (count > 3000)
    		fout << token[0] << "\t" << token[1] << "\t" << token[2] << endl;
	}
  }
}
