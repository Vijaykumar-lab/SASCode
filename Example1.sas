/**************************************************************************************************************
1. Write generic SAS program / macro procedure to read file names from defined directory. 
Minimum requirements: 
- Program should be reusable for any directory.
Expected results:
- History table (SAS dataset) with information about file names (e.g. file_123.txt) under specified directory.
- History table should be stored on dedicated SAS library (other than SASWORK).
**************************************************************************************************************/

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
