libname mylib '/workspaces/myfolder/workbench-session/data';

options set=SSLREQCERT="allow";
%let folder_path = /workspaces/myfolder/workbench-session/;

/*
data mylib.hmeq;
    set sampsio.hmeq;
run;
*/

proc treesplit data = mylib.hmeq;
   input loan value mortdue debtinc derog / level = interval;
   input job / level = nominal;
   target bad / level = nominal;
   prune none;
   saveState rstore = mylib.treeStore_hmeq;
run;

proc astore;
   download rstore = mylib.treeStore_hmeq
            store = "&folder_path.treeAstore.sasast";
run;

/* get token */
%macro myTokenName() / secure;
"Bearer eyJqa3UiOiJodHRwczovL2xvY2FsaG9zdC9TQVNMb2dvbi90b2tlbl9rZXlzIiwia2lkIjoibGVnYWN5LXRva2VuLWtleSIsInR5cCI6IkpXVCIsImFsZyI6IlJTMjU2In0.
eyJzdWIiOiJkMTE0ODRiZC0xYTE0LTQyY2ItOGU3OS1mZjNiOGIxMDM4MzQiLCJ1c2VyX25hbWUiOiJNYXR0aWEuR3VnbGllbG1lbGxpQHNhcy5jb20iLCJvcmlnaW4iOiJh
enVyZSIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3QvU0FTTG9nb24vb2F1dGgvdG9rZW4iLCJhdXRob3JpdGllcyI6WyJTQVNTY29yZVVzZXJzIiwiRGF0YUJ1aWxkZXJzIiwi
R2xvc3NhcnkuR2xvc3NhcnlBZG1pbmlzdHJhdG9ycyIsIkNJUyBWaXlhIEFsd2F5cyBPbiIsIkNhdGFsb2cuU3ViamVjdE1hdHRlckV4cGVydHMiLCJBcHBsaWNhdGlvbkFk
bWluaXN0cmF0b3JzIiwiSUNVcyIsIk1pZ3JhdGlvbkFkbWlucyIsIkVzcmlVc2VycyIsIkNBU0hvc3RBY2NvdW50UmVxdWlyZWQiXSwiY2xpZW50X2lkIjoic2FzLmxhdW5j
aGVyIiwiYXVkIjpbInNhcy5sYXVuY2hlciIsInVhYSJdLCJleHRfaWQiOiI5Vjd0QTJpY01ubzc0WTQ4a1lNZDdRenJIbFRTaHdxeHF3eWpPLUtGdFpzIiwiemlkIjoidWFh
IiwiZ3JhbnRfdHlwZSI6InVybjppZXRmOnBhcmFtczpvYXV0aDpncmFudC10eXBlOmp3dC1iZWFyZXIiLCJ1c2VyX2lkIjoiZDExNDg0YmQtMWExNC00MmNiLThlNzktZmYz
YjhiMTAzODM0IiwiYXpwIjoic2FzLmxhdW5jaGVyIiwic2NvcGUiOlsidWFhLnVzZXIiXSwiZXhwIjoxNzI4Mjg4ODAxLCJpYXQiOjE3MjgyODUyMDEsImp0aSI6ImFhZGVj
ZjZiNjFiZDRlZGM4YTg0MmUxOTY3MzU3YTRlIiwiZW1haWwiOiJNYXR0aWEuR3VnbGllbG1lbGxpQHNhcy5jb20iLCJyZXZfc2lnIjoiNTY0MzY2YTkiLCJjaWQiOiJzYXMu
bGF1bmNoZXIifQ.Q-HxDowPrVY76ovyRvW4EBc7UDAFySZKKdL1XlqqFor_AUSTnL7ttexWHa_TUZV02MtqN2GRQgG2fFn9abB3x54qbZ4YIWrNppxxDUwJR2fQPJkQH_xBa
7mFniFRb1eN6c561QQVfQERbkbgEdrMzSgS70Irfkm9f62QFiPNbJ2Y3GHHGAHVIjz01sPdPRKAdBcoQnWnegDUVHWQ3jpr6oFJcOIdHIAqePf6B_8-8N2NYXsGG-26irRKr
EwvX3IehLPoj8uNzFCgvUyH4737SUHCgHCwcVfBqabdxQV0VIH5LAUV2_7N55CnALZXcfgSuF76E1zPNNY0fH1_4RxSaA"
%mend;

proc registermodel
      name = "TreeAstore"
      description = "Decision Tree Astore Model"
      data = mylib.hmeq
      algorithm = TREE
      function = CLASSIFICATION
      server = "https://create.demo.sas.com"
      oauthtoken = "myTokenName"
      replace;
   project name="registermodelproject" folder="myFolder";
   astoremodel store = "&folder_path.treeAstore.sasast";
   target bad / level=binary event="1";
   assessment;
run;