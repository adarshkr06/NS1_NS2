#include <iostream>
#include <fstream>
#include <cstring>
#include <map>
#include <cstdlib>
using namespace std;

const int MAX_CHARS_PER_LINE = 512;
const int MAX_TOKENS_PER_LINE = 20;
const char* const DELIMITER = ",";

map<int, int> nexthop_map;

int main()
{
  // create a file-reading object
  ifstream fin;
  fin.open("bgptable_dump_101.info"); // open a file
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
      nexthop_map[atoi(token[0])] = atoi(token[2]);
    }
 
  }

  for(map<int, int>::const_iterator it = nexthop_map.begin(); it != nexthop_map.end(); ++it)
  {
    cout << "LOCAL AS : " << it->first << " " << "NEXT HOP : "<< it->second << "\n";
  }

  cout << "MAP LOAD COMPLETE" << endl;
  getchar();
  int success_count = 0;
  fin.close();
  fin.open("bgptable_dump_101.info"); // open a file
  
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
    }
    // process (print) the tokens
    for (int i = 0; i < n; i++) // n = #of tokens
      cout << "Token[" << i << "] = " << token[i] << endl;
    cout << endl;
    if(token[0])
    {
    int as_number = atoi(token[0]);
    while ((nexthop_map[as_number] != 701) && (nexthop_map[as_number] != 0))
    {
	as_number = nexthop_map[as_number];
    }
    success_count++;
    }	
  }

  cout << "THE SUCCESS COUNT " << success_count << endl;

}
