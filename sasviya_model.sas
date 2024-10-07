%let folder_path = /workspaces/myfolder/workbench-session/data;
libname mylib "&folder_path";


proc import datafile="&folder_path/CUSTOMS copy.csv"
    out=mylib.customs(drop=packageID)
    dbms=csv
    replace;
run;

proc print data=mylib.customs (obs=50);
run;

/*
proc forest data=mylib.customs seed=1;
    target inspection / level=nominal;
    input  CertificateOfOrigin EUCitizen
            Perishable  Fragile  PreDeclared 
            MultiplePackage  OnlineDeclaration 
            ExporterValidation  SecuredDelivery  LithiumBatteries 
            ExpressDelivery  PaperlessBilling  Category  EntryPoint
            Origin  PaymentMethod / level=nominal;
    input Volume Weight Price / level=interval;
    savestate rstore=foreststore;
run;
*/

proc freq data=mylib.customs;
    tables Origin*Inspection;
run;

title 'Random forest with original data set';

proc forest data = mylib.customs seed = 12345;
   input Volume Weight Price / level = interval;
   input CertificateOfOrigin EUCitizen Perishable Fragile PreDeclared MultiplePackage Category OnlineDeclaration ExporterValidation 
            SecuredDelivery LithiumBatteries ExpressDelivery EntryPoint Origin PaperlessBilling PaymentMethod  / level=nominal;
   target Inspection / level = nominal;
   output out=work.scoredCustoms copyvars=(Inspection Origin);
run;

proc print data=work.scoredCustoms(obs=30);
run;

data work.scoredCustoms_Africa;
    set work.scoredCustoms;
    where Origin = 'Africa';
run;

title 'Confusion matrix for Origin = Africa';

proc freq data=work.scoredCustoms_Africa;
    tables Inspection*I_Inspection;
run;

title;

data work.scoredCustoms_US;
    set work.scoredCustoms;
    where Origin = 'US';
run;

title 'Confusion matrix for Origin = US';

proc freq data=work.scoredCustoms_US;
    tables Inspection*I_Inspection;
run;

title;

proc assessbias data=work.scoredCustoms; /* scored data set */
   input P_InspectionYes; /* posterior probability of the event to be analyzed */
   target Inspection / event="Yes" level=nominal; /* value of the response variable that represents the event */
   fitstat pvar=P_InspectionNo / pevent="No" ; /* posterior probability for each level in model prediction except the variable specified in the INPUT statement */
   sensitiveVar Origin; /* sensitive variable for which bias is assessed */
run;

title;


/* Train a tabular GAN model and saves the trained model in an analytic store */
proc tabulargan         data=mylib.customs seed=123 numSamples=1500;
    input               Volume Weight Price / level = interval;
    input               CertificateOfOrigin EUCitizen Perishable Fragile PreDeclared MultiplePackage Category OnlineDeclaration ExporterValidation 
                        SecuredDelivery LithiumBatteries ExpressDelivery EntryPoint Origin PaperlessBilling PaymentMethod Inspection / level=nominal;
    gmm                 alpha=1 maxClusters=10 seed=42 VB(maxVbIter=30); /* Gaussian mixture model (GMM) parameters to be used */
    aeoptimization      ADAM LearningRate=0.0001 numEpochs=30; /* hyperparameters of autoencoder model */
    ganoptimization     ADAM(beta1=0.55 beta2=0.95)  numEpochs=50; /* hyperparameters of GAN model */
    train               embeddingDim=64 miniBatchSize=300 useOrigLevelFreq;
    savestate           rstore=work.astore; /* table to use for saving the trained model */
    output              out=work.SynthesizeCustoms; /* table to use for output results */
run;

proc freq data=work.SynthesizeCustoms;
    tables Origin*Inspection;
run;

proc append base=mylib.customs data=work.SynthesizeCustoms;
    where Origin in ('Africa', 'US') and Inspection = 'Yes';
run;

proc freq data=mylib.customs;
    tables Origin*Inspection;
run;

title 'Random forest with augmented data set';

proc forest data = mylib.customs seed = 12345;
   input Volume Weight Price / level = interval;
   input CertificateOfOrigin EUCitizen Perishable Fragile PreDeclared MultiplePackage Category OnlineDeclaration ExporterValidation 
            SecuredDelivery LithiumBatteries ExpressDelivery EntryPoint Origin PaperlessBilling PaymentMethod  / level=nominal;
   target Inspection / level = nominal;
   output out=work.scoredCustoms_augmented copyvars=(Inspection Origin);
run;

proc print data=work.scoredCustoms_augmented(obs=30);
run;

data work.scoredCustoms_augmented_Africa;
    set work.scoredCustoms_augmented;
    where Origin = 'Africa';
run;

title 'Confusion matrix for Origin = Africa';

proc freq data=work.scoredCustoms_augmented_Africa;
    tables Inspection*I_Inspection;
run;

title;

data work.scoredCustoms_augmented_US;
    set work.scoredCustoms_augmented;
    where Origin = 'US';
run;

title 'Confusion matrix for Origin = US';

proc freq data=work.scoredCustoms_augmented_US;
    tables Inspection*I_Inspection;
run;

title;

proc assessbias data=work.scoredCustoms_augmented; /* scored data set */
   input P_InspectionYes; /* posterior probability of the event to be analyzed */
   target Inspection / event="Yes" level=nominal; /* value of the response variable that represents the event */
   fitstat pvar=P_InspectionNo / pevent="No" ; /* posterior probability for each level in model prediction except the variable specified in the INPUT statement */
   sensitiveVar Origin; /* sensitive variable for which bias is assessed */
run;

title;

/*********************************************************************************************/
/* Corresponding SAS Viya platform code for PROC FOREST, PROC ASSESSBIAS AND PROC TABULARGAN */
/*********************************************************************************************/

/*
cas; 
caslib _all_ assign;

proc forest data = casuser.customs seed = 12345;
   input Volume Weight Price / level = interval;
   input CertificateOfOrigin EUCitizen Perishable Fragile PreDeclared MultiplePackage Category OnlineDeclaration ExporterValidation 
            SecuredDelivery LithiumBatteries ExpressDelivery EntryPoint Origin PaperlessBilling PaymentMethod  / level=nominal;
   target Inspection / level = nominal;
   output out=casuser.scoredCustoms copyvars=(Inspection EntryPoint Origin);
run;

proc cas;
	fairAITools.assessBias /
	    event = "Yes",
	    predictedVariables = {"P_InspectionYes", "P_InspectionNo"},
	    response = "Inspection",
	    responseLevels = {"Yes", "No"},
		modelTableType = "NONE",
	    sensitiveVariable = "Origin",
	    table = {name="scoredCustoms", caslib="casuser"};
run;

proc cas; 
    loadactionset "generativeAdversarialNet";
    action tabularGanTrain result = r /
	    table        = {name="customs", caslib="casuser", vars= {"packageID","CertificateOfOrigin","EUCitizen","Perishable",
							"Fragile","PreDeclared","MultiplePackage","Category","OnlineDeclaration","ExporterValidation",
							"SecuredDelivery","LithiumBatteries","ExpressDelivery","EntryPoint","Origin","PaperlessBilling",
							"PaymentMethod","Inspection","Weight","Price","Volume"}},
	    nominals     = {"packageID","CertificateOfOrigin","EUCitizen","Perishable","Fragile","PreDeclared","MultiplePackage",
							"Category","OnlineDeclaration","ExporterValidation","SecuredDelivery","LithiumBatteries",
							"ExpressDelivery","EntryPoint","Origin","PaperlessBilling","PaymentMethod","Inspection"},
	    gmmOptions   = {alpha=1, maxClusters=10, seed=42,
	                     inference={maxVbIter=30}},
	    optimizerAe  = {method='ADAM',numEpochs=3,learningRate=0.0001},
	    optimizerGan = {method='ADAM',numEpochs=5,beta1=0.55,beta2=0.95},
	    embeddingDim = 64,
	    miniBatchSize= 300,
	    seed         = 123,
	    numSamples   = 100,
	    gpu          = {useGPU = False},
	    saveState    = {name="astore", replace=True},
	    casOut       = {name="SynthesizeCustoms", replace=True};

	print r;

run;
quit;
*/
