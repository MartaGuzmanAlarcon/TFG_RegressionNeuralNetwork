
function createFeatureVector(archivo_msqi, archivo_power_Arm, archivo_power_Sternum, register_type)
% Cargar los datos desde el archivo CSV

% Extraer las señales
[~, nombre_base, ~] = fileparts(archivo_msqi);
nombre_registro = erase(nombre_base, "mSQI_Top");

% Importar datos
msqi_original = readmatrix(archivo_msqi, 'NumHeaderLines', 1);

% Importar solo la cuarta columna de power_Arm y power_Sternum -> powertotal
Power_Arm = readmatrix(archivo_power_Arm, 'NumHeaderLines', 1);
Power_Arm = Power_Arm(:,4);

Power_Sternum = readmatrix(archivo_power_Sternum, 'NumHeaderLines', 1);
Power_Sternum = Power_Sternum(:,4);

% Definir parámetros
num_samples = length(msqi_original);
muestra_anterior = 6; % Muestras anteriores al tiempo t
muestra_futura = 5; % Muestras futuras al tiempo t
start_sample = 7;
step_size = 180; % Cada 30 min (180 muestras) para registros largos 

% Inicializar matrices de salida para registros cortos y largos
output_short = [];
output_long = [];

% Recorrer los datos con una ventana centrada en cada punto válido
for t = (muestra_anterior + 1):(num_samples - muestra_futura)
    % Extraer las muestras alrededor del tiempo actual t
    msqi_window = msqi_original(t - muestra_anterior : t + muestra_futura)';
    arm_window = Power_Arm(t - muestra_anterior : t + muestra_futura)';
    sternum_window = Power_Sternum(t - muestra_anterior : t + muestra_futura)';

    % Determinar la clase y tipo
    if strcmp(register_type, 'is_short')
        class_value = 0; % Registros cortos siempre 0
        type_value = 1;
        row = [class_value, type_value, msqi_window, arm_window, sternum_window];
        output_short = [output_short; row]; % Guardar en la matriz de registros cortos
    else
        % Calcular la clase para registros largos (máximo MSQI cada 180 muestras)
        segment_start = max(1, floor((t - start_sample) / step_size) * step_size + start_sample);
        segment_end = min(num_samples, segment_start + step_size - 1);
        class_value = max(msqi_original(segment_start:segment_end)); % Usar máximo MSQI en segmento
        type_value = 0;
        row = [class_value, type_value, msqi_window, arm_window, sternum_window];
        output_long = [output_long; row]; % Guardar en la matriz de registros largos
    end
end

% Definir los encabezados de las columnas
headers = ['Class', 'Type', strcat('mSQI_t', string(-muestra_anterior:muestra_futura)), ...
    strcat('PowerArm_t', string(-muestra_anterior:muestra_futura)), strcat('PowerSternum_t', string(-muestra_anterior:muestra_futura))];

% Guardar registros cortos en CSV
if ~isempty(output_short)
    nombre_file_short = ['FeatureVectors_Short', nombre_registro, '.csv'];
    writetable(array2table(output_short, 'VariableNames', headers), nombre_file_short);
    fprintf('Archivo guardado: %s\n', nombre_file_short);
end

% Guardar registros largos en CSV
if ~isempty(output_long)
    nombre_file_long = ['FeatureVectors_Long', nombre_registro, '.csv'];
    writetable(array2table(output_long, 'VariableNames', headers), nombre_file_long);
    fprintf('Archivo guardado: %s\n', nombre_file_long);
end

end
