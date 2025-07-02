
% Este script procesa dos tipos de registros (cortos y largos) en función
% de los archivos de entrada y genera 'feature vectors' a través de la función
% 'createFeatureVector'.
%
% Definir archivos de entrada

% Definir archivos para registros cortos y largos
files_cortos = {};
files_largos = {'mSQI_FileNames.csv', 'Power_Arm_FileNames.csv', 'Power_Sternum_FileNames.csv'};

% Crear una estructura con los tipos de archivos y su respectivo register_type
file_groups = {files_largos, 'is_long'; files_cortos, 'is_short'}; % 'is_short' o 'is_long'

% Procesar ambos tipos de registros
for k = 1:size(file_groups, 1)
    files = file_groups{k, 1};  % Seleccionar conjunto de archivos
    register_type = file_groups{k, 2}; % Asignar 'is_short' o 'is_long'

    % Verificar si el conjunto de archivos está vacío
    if isempty(files)
        if strcmp(register_type, 'is_long')
            fprintf('No hay archivos largos para procesar.\n');
        elseif strcmp(register_type, 'is_short')
            fprintf('No hay archivos cortos para procesar.\n');
        end
        continue; % Omitir este ciclo y continuar con el siguiente grupo
    end

    % Cargar los datos de los archivos CSV
    data = cell(size(files));
    for i = 1:length(files)
        data{i} = readtable(files{i}, 'ReadVariableNames', false, 'Delimiter', '');
    end

    % Obtener el número de filas
    nRows = height(data{1});

    % Procesar cada fila
    toProcess = cell(1, length(files));
    for i = 1:nRows
        for j = 1:length(files)
            toProcess{j} = data{j}{i, 1}{1}; % Cargar cada archivo para cada fila
        end
        createFeatureVector(toProcess{:}, register_type); % Llamar a la función con los parámetros
    end
end
