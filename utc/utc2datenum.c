#include "mex.h"
#include "time.h"

/*  *** See M-File for Help Description ***
 *
 * Author(s): Abraham Cohn, March 2005 / updated June 2006
*  Copyright Philips Medical Systems
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  int Nelem, mrows, ncols, k;
  time_t gm, utc;
  double timezonediff, localday, datenum;
  double *ptm, *ptzone; /* ptrs to output args */
  double *putc; /* ptr to input UTC vector */
  
  /* Check for proper number of arguments. */
  if (nrhs != 1) {
    mexErrMsgTxt("One input required.");
  } else if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments");
  }
  
  /* The input must be a noncomplex double.*/
  Nelem = mxGetNumberOfElements(prhs[0]);
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
    mexErrMsgTxt("Input must be a noncomplex scalar double.");
  }

  /* Create matrix for the output datenum. */
  plhs[0] = mxCreateDoubleMatrix(mrows, ncols, mxREAL);
  ptm = mxGetPr(plhs[0]);

  if (nlhs > 1) {
    /* create matrix for output time zone diff */
    plhs[1] = mxCreateDoubleMatrix(mrows, ncols, mxREAL);
    ptzone = mxGetPr(plhs[1]);
  }
  
  putc = mxGetPr(prhs[0]); /* pointer to input array */
  
  for (k = 0; k < Nelem; k++) {
    
    utc = (time_t)putc[k];
    // here is a nice reference: http://www.cplusplus.com/ref/ctime/gmtime.html
    gm = mktime(gmtime(&utc));
    
    timezonediff = (double)(utc - gm); /* in seconds */
    /*    mexPrintf("Time Zone Diff in hours (Local - GMT) = %f\n",timezonediff); */
    
    localday = ((double)utc + timezonediff)/86400.0; // convert from seconds to days
    datenum = localday + 719529; // Add days from 1-Jan-0000 to 1-Jan-1970 (get from C to matlab convention)
    
    ptm[k] = datenum; /* assign to output */
    if (nlhs>1)
      ptzone[k] = timezonediff/3600.0; /* convert to hours */
    
  } /* loop over elements */
}
