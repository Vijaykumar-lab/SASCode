/*******************************************************************************************************************
5. Extend previous programs by adding additional logic to import only those files that was not yet imported OR 
imported unsuccessfully (has status Fail). 
Minimum requirements:
- Historical SAS dataset should hold information about file names and import status.
Expected results:
- Program imports only new and previously failed files by checking import history dataset.
*******************************************************************************************************************/
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
/*******
proc print data=Dfiles;
run;****/

Proc sort data=Dfiles;by file_name;run;

/***add status for the files***/
Data Dfiles;
merge Dfiles File_Details;
by file_name;
run;

/**Empty Dataset to store import status **/
Data File_Details;
format file_name $25. Status $10.;
stop;
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
%if &syserr > 0  %then %let status="Fail";
%if &syserr = 0  %then %let status="Successful";

Data File_Status;
set Dfiles;
where file_name="&file_name";
status=&status;
run;
proc append base=File_Details data=File_Status force;
run;



%mend;
/************Macro Import End ********/

/*list all filenames in one macro variable*/
proc sql noprint;
select file_name into: files separated by "," 
from Dfiles where file_name not contains ".sas" and status <> "Successful";
quit;
/*count of filenames in one macro variable*/
proc sql noprint;
select count(file_name) into : filecount
from Dfiles where file_name not contains ".sas" and status <> "Successful";
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

Proc sort data=File_Details noduprecs;by file_name;where file_name <> "" ;run;

Proc print data=file_details;run;

Data Dfiles_Final;
merge Dfiles File_Details;
by file_name;
run;






