function plot_2d_hist(data, AZ, EL, titolo)
    % Controllo per evitare errori nel caso non ci siano i dati
    if isempty(data), return; end 
    
    % Rimozione dati mancanti
    data(any(isnan(data), 2), :) = [];
    
    % Calcolo della densità
    GAZE_DENSITY = hist3(data, {AZ, EL})';
    
    % Plot e caratteristiche
    figure, hold on
    imagesc(AZ, EL, GAZE_DENSITY)
    xlim([min(AZ) max(AZ)]), ylim([min(EL) max(EL)])
    colormap('hot'); colorbar;
    plot(xlim, [0 0], 'w') % Linea orizzonte
    plot([0 0], ylim, 'w') % Linea verticale
    
    % Impostiamo esplicitamente entrambe le direzioni
    set(gca, 'XDir', 'reverse'); % Positivo a sinistra
    set(gca, 'YDir', 'reverse'); % Positivo in basso
    
    xlabel('Azimut (deg)')
    ylabel('Elevation (deg)')
    title(titolo)
end
