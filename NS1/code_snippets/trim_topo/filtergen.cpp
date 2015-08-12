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
  ofstream fout;
  ifstream fin1;
  ifstream fin2;
  int found = 0;
  fout.open("filter.info"); // open a file
  fin2.open("row2.info");

  // read each line of the file
  while (!fin2.eof())
  {
    
    // read an entire line into memory
    char buf[MAX_CHARS_PER_LINE];
    fin2.getline(buf, MAX_CHARS_PER_LINE);
    
    // array to store memory addresses of the tokens in buf
    const char* token[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    
    // parse the line
    token[0] = strtok(buf, DELIMITER); // first token
    if (!token[0])
	break;
    cout  << "\n Parsing row " << token[0] << "in column2"<< endl;
    fin1.open("row1.info");

    while (!fin1.eof())
    {
    // read an entire line into memory
    char buf1[MAX_CHARS_PER_LINE];
    fin1.getline(buf1, MAX_CHARS_PER_LINE);
    
    // array to store memory addresses of the tokens in buf
    const char* token1[MAX_TOKENS_PER_LINE] = {}; // initialize to 0
    
    // parse the line
    token1[0] = strtok(buf1, DELIMITER); // first token
    if (!token1[0])
	break;

    cout  << "\n Parsing row " << token1[0] << "in coulmn1" << endl;

    if (atoi(token[0]) == atoi(token1[0])) {
	found = 1;
    }
    }
    fin1.close();
    cout << "reached here" << endl;
    if (!found)
	fout << "1" << endl;
    else
	fout << "0" << endl;
    found = 0;
  }
}
