function CppPlexFileWrite( fileID, var, dim, format )
%CPlexFileWrite Writes variable data in format CPlex recognizes
%   Writes the variable var to a file opened and tied to fileID in a format
%   that CPlex recognizes for data input (.dat).
%   dim is the number of dimensions the variable occupies
%       0 for single values (dimensionless)
%       x>0 for x-dimensional values
%   format is the format of the value, as a string that describes the
%       format to write the value, as in '%d' or '%1.3f'

    switch dim
        case 0
            fprintf(fileID, [format, '\n'], var);
        case 1
            fprintf(fileID, ['[' format], var(1));
            for index = 2:length(var)
                fprintf(fileID, [',' format], var(index));
            end
            fprintf(fileID, ']\n');
        case 2
            fprintf(fileID, ['[[', format], var(1,1));
            for col = 2:size(var, 2)
                fprintf(fileID, [',' format], var(1, col));
            end
            fpritnf(fileID, ']');
            for row = 2:size(var, 1)
                fprintf(fileID, [',[' format], var(row, 1));
                for col = 2:size(var, 2)
                    fprintf(fileID, [',' format], var(row, col));
                end
                fprintf(fileID, ']');
            end
            fprintf(fileID, ']\n');
        case 3
            fprintf(fileID, ['[[[' format], var(1,1,1));
            for dep = 2:size(var, 3)
                fprintf(fileID, [',' format], var(1, 1, dep));
            end
            fprintf(fileID, ']');
            for col = 2:size(var, 2);
                fprintf(fileID, [',[' format], var(1, col, 1));
                for dep = 2:size(var, 3)
                    fprintf(fileID, [',' format], var(1, col, dep));
                end
                fprintf(fileID, ']');
            end
            fprintf(fileID, ']');
            for row = 2:size(var, 1);
                fprintf(fileID, [',[[' format], var(row, 1, 1));
                for dep = 2:size(var, 3);
                    fprintf(fileID, [',' format], var(row, 1, dep));
                end
                fprintf(fileID, ']');
                for col = 2:size(var, 2);
                    fprintf(fileID, [',[' format], var(row, col, 1));
                    for dep = 2:size(var, 3);
                        fprintf(fileID, [',' format], var(row, col, dep));
                    end
                    fprintf(fileID, ']');
                end
                fprintf(fileID, ']');
            end
            fprintf(fileID, ']\n');
        otherwise
            error('Error\nDimension Not Supported\nNot Written To File');
    end
end
