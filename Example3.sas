/*********************************************************************************************************
3. Merge macro programs of 1 and 2 exercises into single process, so that it would work as single unit. 
Minimum requirements:
- Programs of 1 and 2 exercises should be built in SAS/Macro. 
Expected results: 
- Program is able to read data files and import to SAS datasets.
*********************************************************************************************************/

Libname results "/home/vijaykumarmogal/Results";
*directory path;
%let path=/home/vijaykumarmogal/~vijaykumarmogal/;


data Dfiles(keep=file_name extension);
length fref $8 filename $20;
rc = filename(fref, "&path");
dir = dopen(fref);
filenum = dnum(dir);
	do i = 1 to filenum;
		file_name = dread(dir, i);
		extension=scan(file_name,-1,".");
		output;
end;
run;

proc print data=Dfiles;
run;

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

/*list all filenames in one macro variable*/
proc sql noprint;
select file_name into: files separated by "," 
from Dfiles where file_name not contains ".sas" ;
quit;
/*count of filenames in one macro variable*/
proc sql noprint;
select count(file_name) into : filecount
from Dfiles where file_name not contains ".sas" ;
quit;

%put &files &filecount;

/*Import all files and create respective datasets*/
%macro Data_cre;
%do i=1 %to &filecount;
%let val = %scan("&files",&i,",");
%file_import(&val);
%end;
%mend;

%Data_cre;



