/****************************************************************************************************
2. Write generic SAS program / macro procedure for importing file(s) to SAS dataset(s).
Minimum requirements:
- Program should be easily reusable while importing different data files.
- Program should be capable to import at least two different file types (e.g. txt, csv, xlsx, …). 
Expected result:
- Data files imported to new SAS datasets.
- New datasets should be stored on dedicated SAS library (other than SASWORK).
***************************************************************************************************/
option mprint symbolgen;

Libname results "/home/vijaykumarmogal/Results";
*directory path;
%let path=/home/vijaykumarmogal/~vijaykumarmogal/;

/************Macro Import Start ********/
%macro file_import(file_name);
/* %let full_file=&path&file_name; */

Data _Null_;
call symputx('full_file',"&path&file_name");
run;

proc import datafile="&full_file" out=results.%sysfunc(scan(&file_name,1,"."))
 replace;
run;

%mend;
/************Macro Import End ********/

%file_import(mileage.csv);
%file_import(Sample.txt);
