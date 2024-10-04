libname mylib '/workspaces/myfolder/myscripts/data';

options set=SSLREQCERT="allow";

data mylib.hmeq;
    set sampsio.hmeq;
run;

proc treesplit data = mylib.hmeq;
   input loan value mortdue debtinc derog / level = interval;
   input job / level = nominal;
   target bad / level = nominal;
   prune none;
   saveState rstore = mylib.treeStore_hmeq;
run;

proc astore;
   download rstore = mylib.treeStore_hmeq
            store = "treeAstore.sasast";
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
YjhiMTAzODM0IiwiYXpwIjoic2FzLmxhdW5jaGVyIiwic2NvcGUiOlsidWFhLnVzZXIiXSwiZXhwIjoxNzI4MDMzNzU1LCJpYXQiOjE3MjgwMzAxNTUsImp0aSI6IjYyMGI3
ODVhZGQwODRlOGY4ODdjNGI2MjE0NDUxYTg3IiwiZW1haWwiOiJNYXR0aWEuR3VnbGllbG1lbGxpQHNhcy5jb20iLCJyZXZfc2lnIjoiNTY0MzY2YTkiLCJjaWQiOiJzYXMu
bGF1bmNoZXIifQ.sZ9qK1KJDaM16-KMvS1R14EwRdRorDNQhVax0GK7-IWXXwF25M8hLSJhzl6FOiHIypwcnbf9LH_OqGCZEDcNakfFq6e0W5sjfS7KyppqVjBndOuv1YqOa
jhHrTe879hIHvIFJSK0dmkrSr5aIBGSmVxu1bPzkGMM0gdkY5VuT1zT_Qje9vk0ZFlXbt-hxqebAKgxyqjGZWOTAan7eDecqG7k10Z6aYj_UVqb-TLM_uoQ1NM3FE30LWnPk
HwKMRQs8VPV8MfKWbh1tdT66f_Lw-_K2cELXnMcKJFE1OlRioVMAznUBY05M6pdQPvLTiOG7m_HD_LeH5G-mRw3lBUfrg"
%mend;

proc registermodel
      name = "Tree Astore"
      description = "Decision Tree Astore Model"
      data = mylib.hmeq
      algorithm = TREE
      function = CLASSIFICATION
      server = "https://create.demo.sas.com"
      oauthtoken = "myTokenName"
      replace;
   project name="registermodel-project" folder="myFolder";
   astoremodel store = "treeAstore.sasast";
   target bad / level=binary event="1";
   assessment;
run;