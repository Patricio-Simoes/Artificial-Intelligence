%% Algorítmo de Pesquisa Simulated Annealing.

%% Inicialização do ambiente
fx = @(x) 4 * (sin(5 * pi * x + 0.5).^6) .* exp(log2((x - 0.8).^2));
hold off;
x=linspace(0,1,100);
y=fx(x);
plot(x, y, 'b');
hold on
x_current = rand;
plot(x_current, fx(x_current),'*r');
xlabel('x');
ylabel('F(x)');
title('Algorítmo do Simulated Annealing');
t_max = 400; % Número máximo de iterações. % (40 * 10 = 400 iterações no total).
t = 1; % Contador de iterações.
nRep = 10; % Número de repetições para cada valor de temperatura.
delta = 1/40; % Intervalo de pesquisa, (Vizinhança).
T = 90; % Temperatura inicial. (Máximo).
alfa = 0.94; % Valor de decaímento da temperatura.
values = {}; % Array que guarda os valores necessários para desenhar os gráficos.
i = 1; % Contador do array.

% Algorítmo de pesquisa na vizinhança.
while(t <= t_max)
    rep = 1; % Contador de repetições.
    while(rep <= nRep)
        x_new = x_current + delta * (2 * rand -1); % Novo ponto gerado e ponto de comparação com o anterior.
        % Garante que o novo ponto gerado se encontra dentro do domínio.
        if(x_new >= 0 && x_new <= 1)
            dE = fx(x_new) - fx(x_current); % Gradiente de energia.
            p = 1/(1+exp(abs(dE)/T)); % Probabilidade de aceitar um valor pior.
            % Maximização.
            if(dE > 0)
                x_current = x_new;
                imgx = fx(x_new);
            % Caso em que aceita um valor pior, (Minimização).
            elseif(rand < p)
                x_current = x_new;
                imgx = fx(x_new);
            end
            % Guarda os valores numa estrutura para desenhar os gráfico.
            data.x = x_current;
            data.y = fx(x_current);
            data.de = dE;
            data.t = T;
            data.p = p;
            values{i} = data;
            i = i + 1;
            rep = rep + 1;
        end
    end
    T = T * alfa; % Diminuição da temperatura.
    t = t + 1;
end

% Desenha os gráficos.

% Gráfico do algorítmo.
for j = 1:(nRep * t_max)
    plot(values{j}.x, values{j}.y,'*r');
end

figure;
t = tiledlayout(5, 1, 'TileSpacing', 'compact');

% Gráfico da evolução de x.
ax1 = nexttile;
for j = 1:(nRep * t_max)
    plot(ax1, j, values{j}.x, '*r');
    hold(ax1, 'on');
end
xlabel(ax1, 'Iteração');
ylabel(ax1, 'x');
title(ax1, 'Evolução de x');

% Gráfico da evolução de y.
ax2 = nexttile;
for j = 1:(nRep * t_max)
    plot(ax2, j, values{j}.y, '*b');
    hold(ax2, 'on');
end
xlabel(ax2, 'Iteração');
ylabel(ax2, 'F(x)');
title(ax2, 'Evolução de y');

% Gráfico da evolução de dE.
ax3 = nexttile;
for j = 1:(nRep * t_max)
    plot(ax3, j, values{j}.de, '*g');
    hold(ax3, 'on');
end
xlabel(ax3, 'Iteração');
ylabel(ax3, 'dE');
title(ax3, 'Evolução da Energia');

% Gráfico da evolução de dE.
ax4 = nexttile;
for j = 1:(nRep * t_max)
    plot(ax4, j, values{j}.t, '*y');
    hold(ax4, 'on');
end
xlabel(ax4, 'Iteração');
ylabel(ax4, 'T');
title(ax4, 'Evolução da Temperatura');


% Gráfico da evolução da Probabilida.
ax5 = nexttile;
for j = 1:(nRep * t_max)
    plot(ax5, j, values{j}.p, '*r');
    hold(ax5, 'on');
end
xlabel(ax5, 'Iteração');
ylabel(ax5, 'P');
title(ax5, 'Evolução da Probabilidade');
