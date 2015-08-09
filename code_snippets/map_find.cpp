// map::find
#include <iostream>
#include <map>
#include <stdio.h>

int main ()
{
  std::map<char,int> mymap;
  std::map<char,int>::iterator it;

  mymap['a']=50;
  mymap['c']=150;
  mymap['d']=200;

  it = mymap.find('b');
  if (it == mymap.end())
    mymap['b'] = 300;

  // print content:
  std::cout << "elements in mymap:" << '\n';
  std::cout << "a => " << mymap.find('a')->second << '\n';
  std::cout << "b => " << mymap.find('b')->second << '\n';
  std::cout << "c => " << mymap.find('c')->second << '\n';
  std::cout << "d => " << mymap.find('d')->second << '\n';
  printf("\n PRINTING THE LINE NUMBER %d ", __LINE__);
  return 0;
}

