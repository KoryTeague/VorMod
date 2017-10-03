function [ data ] = CppPlexFileRead( filepath )
%CppPlexFileRead Reads in output file from c++ cplex implementation
%   Standard matlab file read does not parse the output files from cplex
%   correctly.  It only handles 2D, apparently, and the c++ implementation
%   of the cplex optimization problem fails to insert new lines at all the
%   proper times.
%   This function parses the input files for 1-3D variables to be input
%   into Matlab

    %% Setup
    file_str = fileread(filepath);
    data = cell(0);
    a = 0;
    b = 0;
    c = 0;
    num_str = '';
    dim = 0;
    dim_over = 0;
    while file_str(dim_over + 1) == '['
        dim_over = dim_over + 1;
    end
    
    %% Parse Majority
    for index = 1:length(file_str)
        if file_str(index) == '['
            % A dimension deeper, and shift index dimension
            dim = dim + 1;
            switch dim
                case 1
                    a = a + 1;
                    b = 0;
                    c = 0;
                case 2
                    b = b + 1;
                    c = 0;
                case 3
                    c = c + 1;
                otherwise
                    error('Something went wrong\ndim+\n')
            end
        elseif file_str(index) == ']'
            % A dimension shallower
            dim = dim - 1;
        elseif file_str(index) == ','
            % Parse num_str to value
            tmp = str2double(num_str);
            num_str = '';
            switch dim_over
                case 1
                    data{a} = tmp;
                case 2
                    data{a, b} = tmp;
                case 3
                    data{a, b, c} = tmp;
                otherwise
                    error('Something went wrong\n,switch\n')
            end
            switch dim
                case 1
                    a = a + 1;
                    b = 0;
                    c = 0;
                case 2
                    b = b + 1;
                    c = 0;
                case 3
                    c = c + 1;
                otherwise
                    error('Something went wrong\n,\n')
            end
        elseif file_str(index) == ' '
            % Do nothing, ignore
        else
            % Character is part of number
            num_str = [num_str file_str(index)];
        end
    end

    %% Parse Final Element and Convert to Non-Cell Array
    % Elements are added to variable at commas.  No comma after final val
    tmp = str2double(num_str);
    switch dim_over
        case 0
            data = tmp;
        case 1
            data{a} = tmp;
            data = cell2mat(data);
        case 2
            data{a, b} = tmp;
            data = cell2mat(data);
        case 3
            data{a, b, c} = tmp;
            data = cell2mat(data);
        otherwise
            error('Something went wrong\nendswitch\n')
    end
    
end
