%% Algorítmo Genético.

clc;
clear all;
close all;

% Plot da Função e valor máximo
limits=[0,1]; % Limites da pesquisa
set(0,'defaultlinelinewidth',2);
ezplot('4*(sin(5*pi*x+0.5)^6)*exp(log2((x-0.8)^2))',limits)
title('Algorítmo Genético');
axis([0,1,-0.1,2]); % Delimitar os eixos
hold on
% Plots solução do máximo
plot(0.066,1.6332,'sk','Linewidth',2,'markersize',6,'markerfacecolor','r');
% Definições de variáveis
pop_size=5; % Tamanho da populaçao
lchrome=12; % Tamanho do cromossoma
maxgen=80; % Número maximo de gerações
p_cross=0.8; % Probabilidade de cruzamento
p_mutation=0.04; % Probabilidade de mutação
gen=1; % Contador das gerações

% Inicializa a população e guarda os respetivos crossomas na matriz CHROME.
CHROME = init_pop(pop_size, lchrome);

% Calcular aptidão para cada indivíduo na população.
for i = 1:pop_size
    fitnessValues = bin2dec(num2str(CHROME(i, :))) / (2^lchrome - 1);
end

% O vetor 'POP' contém as aptidões da população.
POP = fitnessValues;

% Calcula a aptidão e o valor da variável de decisão.
[CHROME, POP, POP_x] = dec_pop(pop_size, lchrome, limits);

% Calcula as métricas estatísticas da população inicial.
[sumfit, best_idx, max_value, average] = statist(POP);

% Identifica o melhor indivíduo inicial e qual a sua aptidão.
best_chrome = CHROME(best_idx, :);
best_fitness = max_value;

% Inicializa vetores para armazenar os dados de progresso.
best_fitness_over_time = zeros(maxgen, 1);
average_fitness_over_time = zeros(maxgen, 1);

% Plot da função objetivo como pano de fundo.
figure(1);
fplot(@(x) objective_function(x), limits, 'b-', 'LineWidth', 1);
title('Evolução da População no Espaço de Soluções');
xlabel('x');
ylabel('Aptidão');
hold on;

% Ciclo principal do algoritmo genético.
for gen = 1:maxgen
    % Gera a nova população.
    CHROME = generate(pop_size, POP, CHROME, lchrome, p_cross, p_mutation);
    
    % Avalia a nova população.
    [POP, POP_x] = evaluate_population(CHROME, lchrome, limits);
    
    % Calcula estatísticas da nova população.
    [sumfit, best_idx, max_value, average] = statist(POP);

    % Plota a função objetivo novamente como pano de fundo.
    cla; % Limpa o gráfico atual.
    fplot(@(x) objective_function(x), limits, 'b-', 'LineWidth', 1);
    hold on;

    % Plota as soluções da população.
    scatter(POP_x, POP, 'g*');
    plot(POP_x(best_idx), max_value, 'ro', 'MarkerFaceColor', 'r'); % Destaca a melhor solução.

    % Armazena dados para gráficos de progresso.
    best_fitness_over_time(gen) = max_value;
    average_fitness_over_time(gen) = average;
    
    % Atualiza o título com o número da geração.
    title(sprintf('Evolução da População no Espaço de Soluções - Geração %d', gen));
    
    % Pausa breve para a visualização da geração atual.
    pause(0.1);
    
    hold off;
end

% Plot final dos gráficos de progresso.
figure;
subplot(2, 1, 1);
plot(best_fitness_over_time, 'r-', 'LineWidth', 2);
title('Melhor Aptidão por Geração');
xlabel('Geração');
ylabel('Aptidão');

subplot(2, 1, 2);
plot(average_fitness_over_time, 'b-', 'LineWidth', 2);
title('Aptidão Média por Geração');
xlabel('Geração');
ylabel('Aptidão');

%% Funções necessárias para a execução do algoritmo.

% Função que inicializa a populaçao
function CHROME = init_pop(pop_size, lchrome)
    % CHROME - Matriz da população atual
    CHROME = randi([0, 1], pop_size, lchrome);
end

% Função que calcula a aptidão e o valor da variável de decisão.
function [CHROME, POP, POP_x] = dec_pop(pop_size, lchrome, limits)
    % Inicialização da população com valores aleatórios dentro dos limites.
    CHROME = round(rand(pop_size, lchrome));

    % Inicializa o vetor de aptidão e o vetor de variáveis de decisão.
    POP = zeros(1, pop_size);
    POP_x = zeros(1, pop_size);

    % Calcula a aptidão para cada cromossoma.
    for i = 1:pop_size
        % Converte o cromossoma binário num valor real dentro dos limites.
        POP_x(i) = bin2dec(num2str(CHROME(i, :))) / (2^lchrome - 1) * (limits(2) - limits(1)) + limits(1);
        POP(i) = objective_function(POP_x(i));
    end
end

% Função objetivo.
function y = objective_function(x)
    y = 4 * (sin(5 * pi * x + 0.5).^6) .* exp(log2((x - 0.8).^2));
end

% Função que estatísticas da nova população.
function [sumfit, best, max_value, average] = statist(POP)
    sumfit = sum(POP); % Soma das aptidões.
    [max_value, idx_best] = max(POP); % Melhor aptidão e índice.
    best = idx_best; % Índice do melhor cromossoma.
    average = mean(POP); % Média das aptidões.
end

% Seleciona os indivíduos pais da próxima geração com base na aptidão de cada indivíduo.
function index = roulette_selection(POP)
    cumulative_sum = cumsum(POP);
    roulette_pick = rand * cumulative_sum(end);
    index = find(cumulative_sum >= roulette_pick, 1, 'first');
end

% Realiza um cruzamento de um ponto entre dois pais para criar dois filhos.
% O ponto de cruzamento é escolhido aleatoriamente.
function [child1, child2] = single_point_crossover(parent1, parent2, p_cross)
    if rand <= p_cross
        % Verifica se o cruzamento ocorrerá, com base na probabilidade de cruzamento.
        point = randi(length(parent1) - 1);
        child1 = [parent1(1:point), parent2(point+1:end)];
        child2 = [parent2(1:point), parent1(point+1:end)];
    else
        % Se não houver cruzamento, os filhos são cópias dos pais.
        child1 = parent1;
        child2 = parent2;
    end
end

% Aplica mutação a um indivíduo (cromossoma).
function individual = mutate(individual, p_mutation)
    for i = 1:length(individual)
        % Verifica se a mutação ocorrerá para cada gene.
        if rand <= p_mutation
            individual(i) = 1 - individual(i);
        end
    end
end

% Gera uma nova população de cromossomas (CHROME) usando os métodos de seleção, cruzamento e mutação.
function CHROME = generate(pop_size, POP, CHROME, lchrome, p_cross, p_mutation)
    new_CHROME = zeros(size(CHROME));
    for i = 1:2:pop_size
        % Seleção.
        index1 = roulette_selection(POP);
        index2 = roulette_selection(POP);
        
        % Cruzamento.
        [child1, child2] = single_point_crossover(CHROME(index1, :), CHROME(index2, :), p_cross);
        
        % Mutação.
        child1 = mutate(child1, p_mutation);
        child2 = mutate(child2, p_mutation);
        
        new_CHROME(i, :) = child1;
        if i+1 <= pop_size
            new_CHROME(i+1, :) = child2;
        end
    end
    CHROME = new_CHROME;
end

% Calcula a aptidão da população.
function [POP, POP_x] = evaluate_population(CHROME, lchrome, limits)
    pop_size = size(CHROME, 1); % Número de indivíduos na população.
    POP = zeros(1, pop_size); % Vetor de aptidão.
    POP_x = zeros(1, pop_size); % Vetor de valores da variável de decisão.

    % Itera sobre a população para calcular a aptidão de cada cromossoma.
    for i = 1:pop_size
        % Converte o cromossoma binário em valor real dentro dos limites.
        x = bin2dec(num2str(CHROME(i, :))) / (2^lchrome - 1);
        x = x * (limits(2) - limits(1)) + limits(1);
        POP_x(i) = x; % Armazena o valor real da variável de decisão.
        POP(i) = objective_function(x); % Calcula e armazena a aptidão.
    end
end
