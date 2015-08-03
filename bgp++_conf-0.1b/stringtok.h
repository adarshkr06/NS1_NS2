// STL Code for tokenizing strings
// George F. Riley, Georgia Tech
// Taken from WWW, author unknown

#ifndef __STRINGTOK_H__
#define __STRINGTOK_H__
#include <string>
#include <cstring>    // for strchr
#include <list>
#include <map>
using namespace std;
// Code for tokenizing the lines
namespace {
    inline bool
    isws (char c, char const * const wstr)
    {
        return (strchr(wstr,c) != NULL);
    }
}


template <typename Container>
void
stringtok (Container &l, string const &s, char const * const ws = " \t\n")
{
    const string::size_type  S = s.size();
          string::size_type  i = 0;

    while (i < S) {
        // eat leading whitespace
        while ((i < S) && (isws(s[i],ws)))  ++i;
        if (i == S)  return;  // nothing left but WS

        // find end of word
        string::size_type  j = i+1;
        while ((j < S) && (!isws(s[j],ws)))  ++j;

        // add word
        l.push_back(s.substr(i,j-i));

        // set up for next loop
        i = j+1;
    }
}
#endif

