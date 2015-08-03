#include <iostream>
#include <cstdlib>

using std::cout;
using std::endl;

#include <fstream>
using std::ifstream;
using std::ofstream;
#include <cstring>

const int MAX_CHARS_PER_LINE = 512;
const int MAX_TOKENS_PER_LINE = 20;
const char* const DELIMITER = "|";

int main()
{
  // create a file-reading object
  ifstream fin;
  fin.open("19980101.as-rel.txt"); // open a file
  ofstream fout;
  fout.open("router.info");
  if (!fin.good()) 
    return 1; // exit if file not found

  // read each line of the file
  while (!fin.eof())
  {
    // read an entire line into memory
    char buf[MAX_CHARS_PER_LINE];
    fin.getline(buf, MAX_CHARS_PER_LINE);
    
    // parse the line into blank-delimited tokens
    int n = 0; // a for-loop index
    
    // array to store memory addresses of the tokens in buf
    const char* token[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    
    // parse the line
    token[0] = strtok(buf, DELIMITER); // first token
    if (token[0]) // zero if line is blank
    {
      for (n = 1; n < MAX_TOKENS_PER_LINE; n++)
      {
        token[n] = strtok(0, DELIMITER); // subsequent tokens
        if (!token[n]) break; // no more tokens
      }
    
    int as_rel = atoi(token[2]);

    if (as_rel == -1)
	fout << token[0] << "\t" << token[1] << "\t" << "custfull" << endl;

    if (as_rel == 0)
	fout << token[0] << "\t" << token[1] << "\t" << "peer" << endl;

    }
  }
   fin.close();
   fout.close();
}
