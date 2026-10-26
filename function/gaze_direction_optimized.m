%% COLLECT GAZE DIRECTION DATA
clear; clc; close all;

% --- CONFIGURAZIONE ---
ROOT = 'GAZE_DATA'; % Senza la slash finale per evitare problemi mac/windows e poi uso fullfile che crea il percorso corretto sia su Mac che su Windows
addpath('function'); % funzione che serve a caricare il file con la funzione creata dalla cartella 'function'

opts = detectImportOptions(fullfile(ROOT, 'TASK_LIST.xlsx')); % funzione che crea un libretto di istruzioni (opts) dal file aperto con fullfile
opts.VariableNames = {'Subject', 'FileID', 'Task', 'Order'};
T = readtable(fullfile(ROOT, 'TASK_LIST.xlsx'), opts); % carico i dati dentro la variabile T (table)

SBJ_LIST = unique(T.Subject, 'stable'); % prendo la colonna dei sogetti così come nell'ordine del file excel
TASK_LIST = unique(T.Task, 'stable'); % prendo la colonna dei task così come nell'ordine del file excel

NBIN = 32; G_LIM = 50; % divido il campo visivo in 32 "celle" e lo analizzo nell'intervallo [-G_LIM, G_LIM]
AZ_bins = linspace(-G_LIM, G_LIM, NBIN);
EL_bins = linspace(-G_LIM, G_LIM, NBIN);

indoor_tasks = {'SAND', 'TEXT', 'GAME', 'CAFE', 'LOOK'};


%% --- FASE 1: CARICAMENTO SINGOLO DEI DATI ---
fprintf('Caricamento dati in memoria...\n');
all_gaze_data = cell(height(T), 1); % Cella per il gaze
all_time_data = cell(height(T), 1); % Cella per il tempo
all_verg_data = cell(height(T), 1); % Cella per la vergenza
valid_files = false(height(T), 1); % Variabile booleana per il controllo di presenza del dato

for i = 1:height(T)
    path = fullfile(ROOT, T.Subject{i}, T.Task{i}, 'FIXATION_POINTS_DATA.mat'); % Cerco il file .mat per ogni task/soggetto
    
    if exist(path, 'file')
        d = load(path);
        all_gaze_data{i} = d.FIXATION_POINTS_DATA(:, 7:8); % Estrazione dati gaze
        all_time_data{i} = straighten(d.FIXATION_POINTS_DATA(:, 2)); % Estrazione dati temporali
        all_verg_data{i} = d.FIXATION_POINTS_DATA(:, 9); % Estrazione dati vergence
        
        valid_files(i) = true; 
    else
        fprintf('File mancante: %s\n', path);
    end
end


%% --- FASE 2: GENERAZIONE PLOT ---

% --- OBIETTIVO 1: UN PLOT PER SOGGETTO ---
fprintf('Generazione plot per ogni Soggetto...\n');
for s = 1:length(SBJ_LIST)
    % Trova gli indici delle righe di questo soggetto con file validi
    idx = strcmp(T.Subject, SBJ_LIST{s}) & valid_files;
    
    % cell2mat unisce tutte le matrici selezionate
    data_sbj = cell2mat(all_gaze_data(idx)); 
    plot_2d_hist(data_sbj, AZ_bins, EL_bins, ['Soggetto: ' SBJ_LIST{s}]);
end

% --- OBIETTIVO 2: UN PLOT PER TASK ---
fprintf('Generazione plot per ogni Task...\n');
for t = 1:length(TASK_LIST)
    idx = strcmp(T.Task, TASK_LIST{t}) & valid_files;
    data_task = cell2mat(all_gaze_data(idx));
    plot_2d_hist(data_task, AZ_bins, EL_bins, ['Task: ' TASK_LIST{t}]);
end

% --- OBIETTIVO 3: INDOOR VS OUTDOOR ---
fprintf('Generazione plot Indoor vs Outdoor...\n');

idx_in = ismember(T.Task, indoor_tasks) & valid_files; % ismember controlla se i task nella colonna appartengono alla lista indoor
idx_out = ~ismember(T.Task, indoor_tasks) & valid_files; % Il simbolo ~ significa NOT (! in python/C) (in questo esempio mi dice Outdoor)

data_in = cell2mat(all_gaze_data(idx_in));
data_out = cell2mat(all_gaze_data(idx_out));

plot_2d_hist(data_in, AZ_bins, EL_bins, 'Ambiente: INDOOR');
plot_2d_hist(data_out, AZ_bins, EL_bins, 'Ambiente: OUTDOOR');


%% --- EXTRA 1: GRAFICI TEMPORALI PER OGNI PROVA ---
% fprintf('Generazione grafici temporali...\n');
% if ~exist('PLOT_TEMPORALI', 'dir')
%     mkdir('PLOT_TEMPORALI');
% end
% 
% for i = 1:height(T)
%     if valid_files(i) % Controllo se c'è il dato precedentemente acquisito
% 
%         % Ottengo gli istanti temporali
%         raw_time = all_time_data{i};
%         GAZE_DATA = all_gaze_data{i};
% 
%         % Converto il tempo in secondi partendo da zero
%         TIME = (raw_time - raw_time(1)) / 1000;
% 
%         % Creazione Grafico
%         fig = figure('Visible', 'off'); 
%         hold on
%         plot(TIME, GAZE_DATA(:,1), 'b') 
%         plot(TIME, GAZE_DATA(:,2), 'Color','#FF8800') 
% 
%         grid on
%         xlabel('Time (s)')
%         ylabel('Deg')
%         legend('Azimuth', 'Elevation')
%         title(['Subject: ' T.Subject{i} ' - Task: ' T.Task{i}])
% 
%         file_name = fullfile('PLOT_TEMPORALI', [T.Subject{i} '_' T.Task{i} '.png']);
%         saveas(fig, file_name);
%         close(fig); 
%     end
% end
% fprintf('I grafici sono stati salvati nella cartella PLOT_TEMPORALI.\n');


%% --- EXTRA 2: ANALISI VERGENZA (INDOOR VS OUTDOOR) ---
fprintf('Calcolo Statistiche di Vergenza...\n');

% Estrazione e pulizia dati
verg_in = cell2mat(all_verg_data(idx_in));
verg_out = cell2mat(all_verg_data(idx_out));
verg_in(isnan(verg_in)) = [];
verg_out(isnan(verg_out)) = [];

% Creazione raggruppamenti per il Boxplot
gruppi_verg = [ones(length(verg_in), 1); 2 * ones(length(verg_out), 1)];
dati_verg = [verg_in; verg_out];

figure('Name', 'Vergenza: Indoor vs Outdoor', 'Color', 'w');
boxplot(dati_verg, gruppi_verg, 'Labels', {'INDOOR', 'OUTDOOR'});
ylabel('Vergenza (deg)');
title('Distribuzione della Vergenza (Profondità di Sguardo)');
grid on;

% Stampiamo in console i valori mediani per la presentazione
fprintf('\n--- RISULTATI VERGENZA ---\n');
fprintf('Mediana INDOOR: %.2f gradi (Sguardo più da vicino)\n', median(verg_in));
fprintf('Mediana OUTDOOR: %.2f gradi (Sguardo più verso l''infinito)\n', median(verg_out));
fprintf('--------------------------\n');


%% --- EXTRA 3: DISPERSIONE DELLO SGUARDO (VARIANZA) ---
fprintf('Calcolo Dispersione Spaziale...\n');

% Pulizia dei dati Azimut/Elevation già raggruppati in data_in e data_out
data_in_clean = data_in(~any(isnan(data_in), 2), :);
data_out_clean = data_out(~any(isnan(data_out), 2), :);

figure('Name', 'Dispersione Sguardo: Indoor vs Outdoor', 'Color', 'w');

% Subplot 1: Dispersione Orizzontale (Azimut)
subplot(1, 2, 1);
gruppi_az = [ones(length(data_in_clean), 1); 2 * ones(length(data_out_clean), 1)];
dati_az = [data_in_clean(:,1); data_out_clean(:,1)];
boxplot(dati_az, gruppi_az, 'Labels', {'INDOOR', 'OUTDOOR'});
ylabel('Azimut (deg)');
title('Dispersione Orizzontale');
grid on;

% Subplot 2: Dispersione Verticale (Elevation)
subplot(1, 2, 2);
gruppi_el = [ones(length(data_in_clean), 1); 2 * ones(length(data_out_clean), 1)];
dati_el = [data_in_clean(:,2); data_out_clean(:,2)];
boxplot(dati_el, gruppi_el, 'Labels', {'INDOOR', 'OUTDOOR'});
ylabel('Elevation (deg)');
title('Dispersione Verticale');
grid on;

% Ribaltiamo l'asse Y dell'Elevation per rispettare la convenzione
set(gca, 'YDir', 'reverse');