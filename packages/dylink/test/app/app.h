#define EXPORTED_SYMBOL __attribute__((visibility("default")))

struct PyObjectX {
  int thingy;
};

typedef struct PyObjectX PyObject;

PyObject _Py_NoneStruct;

#define PyNone (&_Py_NoneStruct)

typedef int (*ADD_FUN_PTR)(int);