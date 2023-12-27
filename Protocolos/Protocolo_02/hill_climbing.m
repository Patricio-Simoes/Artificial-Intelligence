%% Algorítmo de Pesquisa Hill Climbing sem reinicialização múltipla.

clc;
clear all;
close all;

%% Inicialização do ambiente
fx = @(x) 4 * (sin(5 * pi * x + 0.5).^6) .* exp(log2((x - 0.8).^2));
hold off;
x=linspace(0,1,100);
x_array = {}; % Array que guarda a posição, (evolução do x).
j = 1; % Iterados de posições no array de evolução.
re = 10; % Número de reinicializações do algorítmo.
y=fx(x);
plot(x,y,'b');
hold
x_current = rand;
plot(x_current, fx(x_current),'*r');
xlabel('x');
ylabel('F(x)');
title('Algorítmo da Subida da Colina');
t = 1; % Contador de iterações.
t_max = 400; % Número máximo de iterações.
delta = 1/200; % Intervalo de pesquisa, (Vizinhança).

% Algorítmo de pesquisa na vizinhança.

while(t <= t_max)
    x_new = x_current + delta * (2 * rand -1); % Novo ponto gerado e ponto de comparação com o anterior.
    if(fx(x_current) < fx(x_new))
        x_current = x_new; % Troca a posição do x atual para o novo x.
        data.fx = fx(x_current);
        data.x = x_current;
        data.time = t;
        x_array{j} = data; % Guarda a posição do x no array de evolução.
        j = j + 1;
    end
    plot(x_current, fx(x_current),'*r');
    t = t + 1;
end

% Gráfico de evolução da posição do x ao longo do tempo.
figure;
plot(cell2mat(cellfun(@(x) x.time, x_array, 'UniformOutput', false)), cell2mat(cellfun(@(x) x.x, x_array, 'UniformOutput', false)), 'g');
xlabel('Tempo');
ylabel('Posição de x');
title('Evolução da posição de x ao longo do tempo');

% Gráfico de evolução imagem de x ao longo do tempo.
figure;
plot(cell2mat(cellfun(@(x) x.time, x_array, 'UniformOutput', false)), cell2mat(cellfun(@(x) x.fx, x_array, 'UniformOutput', false)), 'g');
xlabel('Tempo');
ylabel('F(x)');
title('Evolução da imagem de x ao longo do tempo');
