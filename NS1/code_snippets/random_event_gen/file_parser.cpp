#include <iostream>
using std::cout;
using std::endl;

#include <fstream>
using std::ifstream;
using std::ofstream;

#include <cstring>

const int MAX_CHARS_PER_LINE = 512;
const int MAX_TOKENS_PER_LINE = 20;
const char* const DELIMITER = "\t";

int main()
{
  // create a file-reading object
  ifstream fin1;
  ifstream fin2;
  ofstream fout;

  fin1.open("as_numbers.info"); // open a file
  fin2.open("router_ids.info"); // open a file
  fout.open("as2router_id_map.info");  
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
    if (!token1[0]) // zero if line is blank
    {
	break;
    }
    fout << token1[0] << "\t" << token2[0] << endl;

  }
}
