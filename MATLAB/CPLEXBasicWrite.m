function CPLEXBasicWrite( DATA )
%CPLEXWrite Writes one data variable file in format for CPLEX to read
%   Writes the given data to a dummy (temp) .dat file: 'temp.dat'
%   This data is written in a form appropriate of its dimension in order
%   to be read into a CPLEX model.  This 'temp.dat' file has no additional
%   data within: no header, no comments, only a single line of data.
%   Parameters:
%       DATA is the variable being written to file

    if isvector(DATA)
        dim = 1;
    else
        dim = ndims(DATA);
    end
    
    fileID = fopen('temp.dat', 'w');
    CppPlexFileWrite(fileID, DATA, dim, '%1.5f');
    fclose(fileID);

end

