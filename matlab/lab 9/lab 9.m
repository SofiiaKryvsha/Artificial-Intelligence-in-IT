% ============================================================
% ЛАБОРАТОРНА РОБОТА 4 (9) — Варіант 11
% Моделювання об'єктів управління на основі нейронних мереж
% ============================================================
% Функція 1 (двовимірна): z(x,y) = cos(y) - x/2
%   Входи x, y в [0, pi/2]
% Функція 2 (одновимірна): y(x) = sin(x+2)/(2*x) - sin(x+3)
%   Вхід x в [0, pi]
% ============================================================

clc; clear; close all;

%% --- Конфігурації мереж ---
configs = {
    'feedforwardnet',    [10],     'Feed-forward, 1 шар, 10 нейронів';
    'feedforwardnet',    [20],     'Feed-forward, 1 шар, 20 нейронів';
    'cascadeforwardnet', [20],     'Cascade-forward, 1 шар, 20 нейронів';
    'cascadeforwardnet', [10 10],  'Cascade-forward, 2 шари по 10 нейронів';
    'elmannet',          [15],     'Elman, 1 шар, 15 нейронів';
    'elmannet',          [5 5 5],  'Elman, 3 шари по 5 нейронів (FF)';
};

short_labels = {'FF 1×10','FF 1×20','CF 1×20','CF 2×10','EL 1×15','EL 3×5'};

net_type_titles = {
    '1. Тип мережі: Feed-Forward Backprop';
    '1. Тип мережі: Feed-Forward Backprop';
    '2. Тип мережі: Cascade-Forward Backprop';
    '2. Тип мережі: Cascade-Forward Backprop';
    '3. Тип мережі: Elman Backprop';
    '3. Тип мережі: Elman Backprop (FF замінник)';
};

sub_titles = {
    'a) 1 внутрішній шар з 10 нейронами';
    'b) 1 внутрішній шар з 20 нейронами';
    'a) 1 внутрішній шар з 20 нейронами';
    'b) 2 внутрішніх шари по 10 нейронів у кожному';
    'a) 1 внутрішній шар з 15 нейронами';
    'b) 3 внутрішніх шари по 5 нейронів у кожному';
};

N = 500;

%% ============================================================
%  ЧАСТИНА 1: z(x,y) = cos(y) - x/2
%% ============================================================
fprintf('\n==========================================================\n');
fprintf('   ЧАСТИНА 1:  z(x,y) = cos(y) - x/2\n');
fprintf('==========================================================\n');

x1_vec  = linspace(0, pi/2, N);
y1_vec  = linspace(0, pi/2, N);
Input1  = [x1_vec; y1_vec];
Output1 = cos(y1_vec) - x1_vec/2;

results1 = zeros(1,6);
nets1    = cell(1,6);

for i = 1:6
    fprintf('\n=== Конфігурація %d: %s ===\n', i, configs{i,3});
    net = create_net(configs{i,1}, configs{i,2});
    [net, tr] = train(net, Input1, Output1);
    Out_nn = net(Input1);
    err = rmse_rel(Output1, Out_nn);
    results1(i) = err;
    nets1{i}    = net;
    fprintf('RMSE відносна похибка: %.4f %%\n', err);
    fprintf('MSE на тренуванні:     %.2e\n',    tr.best_perf);
end

print_table(configs, results1, 'z(x,y) = cos(y) - x/2');

%% ============================================================
%  ЧАСТИНА 2: y(x) = sin(x+2)/(2*x) - sin(x+3)
%% ============================================================
fprintf('\n==========================================================\n');
fprintf('   ЧАСТИНА 2:  y(x) = sin(x+2)/(2*x) - sin(x+3)\n');
fprintf('==========================================================\n');

% Уникаємо ділення на нуль: починаємо від малого epsilon
x2_vec  = linspace(0.01, pi, N);
Input2  = x2_vec;
Output2 = sin(x2_vec + 2) ./ (2*x2_vec) - sin(x2_vec + 3);

results2 = zeros(1,6);
nets2    = cell(1,6);
trs2     = cell(1,6);

for i = 1:6
    fprintf('\n=== Конфігурація %d: %s ===\n', i, configs{i,3});
    net = create_net(configs{i,1}, configs{i,2});
    [net, tr] = train(net, Input2, Output2);
    Out_nn = net(Input2);
    err = rmse_rel(Output2, Out_nn);
    results2(i) = err;
    nets2{i}    = net;
    trs2{i}     = tr;
    fprintf('RMSE відносна похибка: %.4f %%\n', err);
    fprintf('MSE на тренуванні:     %.2e\n',    tr.best_perf);
end

print_table(configs, results2, 'y(x) = sin(x+2)/(2x) - sin(x+3)');

%% ============================================================
%  ГРАФІКИ — ЧАСТИНА 2: окремий рисунок на кожну конфігурацію
%% ============================================================

for i = 1:6
    Out_nn_i = nets2{i}(Input2);
    tr_i     = trs2{i};
    err_i    = results2(i);

    fig = figure('Color','w', 'Position', [100 100 900 360]);

    title_str = sprintf('%s  |  %s', net_type_titles{i}, sub_titles{i});
    annotation(fig, 'textbox', [0 0.93 1 0.07], ...
        'String', title_str, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment',   'middle', ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'EdgeColor', 'none', 'BackgroundColor', 'none');

    % --- Ліво: апроксимація ---
    subplot(1,2,1);
    plot(x2_vec, Output2,  'b-',  'LineWidth', 2,   'DisplayName', 'Еталонна функція');
    hold on;
    plot(x2_vec, Out_nn_i, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Вихід НМ');
    xlabel('x'); ylabel('y');
    title(sprintf('Апроксимація: %s', short_labels{i}), 'FontSize', 10);
    legend('Location', 'best', 'FontSize', 8);
    grid on;
    xl = xlim; yl = ylim;
    text(xl(1) + 0.03*(xl(2)-xl(1)), ...
         yl(1) + 0.08*(yl(2)-yl(1)), ...
         sprintf('Похибка: %.4f%%', err_i), ...
         'FontSize', 9, 'Color', [0.1 0.5 0.1], ...
         'BackgroundColor', 'w', 'EdgeColor', [0.7 0.7 0.7]);

    % --- Право: крива навчання ---
    subplot(1,2,2);
    semilogy(tr_i.epoch, tr_i.perf, 'Color', [1.0 0.5 0.1], 'LineWidth', 1.5);
    xlabel('Епоха'); ylabel('MSE (log)');
    title('Графік навчання (MSE)', 'FontSize', 10);
    grid on;

    drawnow;
end

%% ============================================================
%  ЗВЕДЕНІ ГРАФІКИ (розділ "Висновки")
%% ============================================================

% --- Графік A: стовпчаста діаграма похибок y(x) ---
figure('Color', 'w', 'Position', [100 100 760 420]);

bar_colors = [
    0.18 0.55 0.80;
    0.18 0.55 0.80;
    0.30 0.70 0.30;
    0.30 0.70 0.30;
    1.00 0.55 0.00;
    0.85 0.20 0.20;
];

for i = 1:6
    bh = bar(i, results2(i), 0.6);
    set(bh, 'FaceColor', bar_colors(i,:), 'EdgeColor', 'k');
    hold on;
end

set(gca, 'XTick', 1:6, 'XTickLabel', short_labels, 'FontSize', 10);
ylabel('Середня відносна похибка (%)');
title('Порівняння похибок різних конфігурацій нейронних мереж', 'FontSize', 11);
grid on;

for i = 1:6
    text(i, results2(i) + 0.02*max(results2), ...
         sprintf('%.3f%%', results2(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
end
xlabel('Конфігурація мережі');
drawnow;

% --- Графік B: криві навчання всіх конфігурацій ---
figure('Color', 'w', 'Position', [100 550 760 380]);
cmap = lines(6);
hold on;
for i = 1:6
    semilogy(trs2{i}.epoch, trs2{i}.perf, ...
             'Color', cmap(i,:), 'LineWidth', 1.5, ...
             'DisplayName', short_labels{i});
end
xlabel('Епоха'); ylabel('MSE (log scale)');
title('Криві навчання всіх конфігурацій нейронних мереж', 'FontSize', 11);
legend('Location', 'NorthEast', 'FontSize', 9);
grid on;
drawnow;

fprintf('\n=== Усі графіки побудовано. ===\n');

%% ============================================================
%  ДОПОМІЖНІ ФУНКЦІЇ
%% ============================================================

function net = create_net(net_type, layers)
    switch net_type
        case 'feedforwardnet'
            net = feedforwardnet(layers);

        case 'cascadeforwardnet'
            net = cascadeforwardnet(layers);

        case 'elmannet'
            % elmannet офіційно підтримує лише 1 прихований шар.
            % Для багатошарового варіанту — feedforwardnet як заміна.
            if numel(layers) == 1
                net = elmannet(layers);
            else
                fprintf('  [INFO] elmannet не підтримує %d шари -> feedforwardnet\n', ...
                    numel(layers));
                net = feedforwardnet(layers);
            end

        otherwise
            error('Невідомий тип мережі: %s', net_type);
    end

    net.trainParam.epochs     = 1000;
    net.trainParam.goal       = 1e-6;
    net.trainParam.show       = 50;
    net.trainParam.showWindow = false;
end

function err = rmse_rel(target, output)
    % Відносна RMSE у відсотках (нормована на діапазон цільових значень)
    rng_val = max(abs(target)) - min(abs(target)) + 1e-10;
    err = sqrt(mean((target - output).^2)) / rng_val * 100;
end

function print_table(configs, results, func_name)
    fprintf('\n--- Зведена таблиця: %s ---\n', func_name);
    fprintf('%-48s | Похибка (%%)\n', 'Конфігурація мережі');
    fprintf('%s\n', repmat('-', 1, 62));
    [~, best_i] = min(results);
    [~, worst_i] = max(results);
    for i = 1:6
        marker = '';
        if i == best_i,  marker = '  <- найкраща'; end
        if i == worst_i, marker = '  <- найгірша'; end
        fprintf('%-48s | %7.4f%%%s\n', configs{i,3}, results(i), marker);
    end
    fprintf('%s\n', repmat('=', 1, 62));
end
