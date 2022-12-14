
#include <string>
#include "abc.h"
#include "iostream"
#include <iostream>

struct Msg {
    std::string str;
    int         id;
};

class test {
public:
    test();
    test(test&&)                 = default;
    test(const test&)            = default;
    test& operator=(test&&)      = default;
    test& operator=(const test&) = default;
    ~test();

private:
    /*
     * comments
     * comments
     */
    void func(int a, char* b, size_t c);

    void func_2(const char* a, const int b);

    const char* stre(int a);

    void funnn(size_t a);

    struct Msg funcc();

    void test_func(struct Msg msg);

    int test1();
    bool test2();
    char test3();
    int* test4();
    double test6();
    void test7();
};
