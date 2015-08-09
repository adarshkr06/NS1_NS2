#include <iostream>
using std::cout;
using std::endl;

#include <fstream>
using std::ifstream;
using std::ofstream;

#include <cstring>

const int MAX_CHARS_PER_LINE = 512;
const int MAX_TOKENS_PER_LINE = 20;
const char* const DELIMITER = " ";

int main()
{
  // create a file-reading object
  ifstream fin1;
  ifstream fin2;
  ofstream fout;
  fin1.open("router_ids.info"); // open a file
  fin2.open("as_numbers.info"); // open a file
  fout.open("bgpd5_neighbors.info"); // open a file
  if (!fin1.good()) 
    return 1; // exit if file not found
  
  if (!fin2.good()) 
    return 1; // exit if file not found
  // read each line of the file

  while (!fin1.eof())
  {
    // read an entire line into memory
    char buf[MAX_CHARS_PER_LINE];
    fin1.getline(buf, MAX_CHARS_PER_LINE);
    
    char buf1[MAX_CHARS_PER_LINE];
    fin2.getline(buf1, MAX_CHARS_PER_LINE);

    // parse the line into blank-delimited tokens
    int n = 0; // a for-loop index
    int m = 0; // a for-loop index
    
    // array to store memory addresses of the tokens in buf
    const char* token1[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    const char* token2[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    
    // parse the line
    token1[0] = strtok(buf, DELIMITER); // first token
    if (token1[0]) // zero if line is blank
    {
      for (n = 1; n < MAX_TOKENS_PER_LINE; n++)
      {
        token1[n] = strtok(0, DELIMITER); // subsequent tokens
        if (!token1[n]) break; // no more tokens
      }
    }

    // parse the line
    token2[0] = strtok(buf1, DELIMITER); // first token
    if (token2[0]) // zero if line is blank
    {
      for (m = 1; m < MAX_TOKENS_PER_LINE; m++)
      {
        token2[m] = strtok(0, DELIMITER); // subsequent tokens
        if (!token2[m]) break; // no more tokens
      }
    }

    // process (print) the tokens
    for (int i = 0; i < n; i++) // n = #of tokens
      cout << "Token[" << i << "] = " << token1[i] << endl;
    cout << endl;
    // process (print) the tokens
    for (int i = 0; i < m; i++) // n = #of tokens
      cout << "Token[" << i << "] = " << token2[i] << endl;
    cout << endl;

    fout << token1[0] << " " << token1[1] << " " << token2[0] << " " << token2[1] << endl;
    fout << token1[0] << " " << token1[1] << " advertisement-interval 60" << endl;
  }
}
