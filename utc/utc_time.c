#include "mex.h"
#include "time.h"

// Abraham Cohn,  3/17/2005
// Philips Medical Systems

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  time_t utc;
  
  if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments");
  }
  
  // Here is a nice reference: http://www.cplusplus.com/ref/ctime/time.html
  time(&utc);
  //mexPrintf("UTC time displayed in local zone: %s",ctime(&utc));
  //mexPrintf("UTC time displayed in GMT: %s",asctime(gmtime(&utc)));
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateScalarDouble((double)utc);
   
}