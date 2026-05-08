% ============================================================
% ЛАБОРАТОРНА РОБОТА 5
% Моделювання нейронної мережі Хебба
% Розпізнавання букв: С, О, Н, Я
% Сітка 7x5 = 35 пікселів (біполярне кодування: +1/-1)
% ============================================================

clc; clear; close all;

%% --- Крок 1. Визначення зображень букв (7x5 сітка, біполярне) ---

% Буква С
S_img = [-1,  1,  1,  1, -1;
          1, -1, -1, -1,  1;
          1, -1, -1, -1, -1;
          1, -1, -1, -1, -1;
          1, -1, -1, -1, -1;
          1, -1, -1, -1,  1;
         -1,  1,  1,  1, -1];

% Буква О
O_img = [-1,  1,  1,  1, -1;
          1, -1, -1, -1,  1;
          1, -1, -1, -1,  1;
          1, -1, -1, -1,  1;
          1, -1, -1, -1,  1;
          1, -1, -1, -1,  1;
         -1,  1,  1,  1, -1];

% Буква Н
N_img = [ 1, -1, -1, -1,  1;
           1, -1, -1, -1,  1;
           1, -1, -1, -1,  1;
           1,  1,  1,  1,  1;
           1, -1, -1, -1,  1;
           1, -1, -1, -1,  1;
           1, -1, -1, -1,  1];

% Буква Я
Ya_img = [ 1,  1,  1,  1, -1;
            1, -1, -1, -1,  1;
            1, -1, -1, -1,  1;
            1,  1,  1,  1, -1;
            1, -1,  1, -1, -1;
            1, -1, -1,  1, -1;
            1, -1, -1, -1,  1];

% Перетворення в вектори-стовпці (35x1)
x1 = S_img(:);
x2 = O_img(:);
x3 = N_img(:);
x4 = Ya_img(:);

% Навчальна вибірка
% С -> [+1, -1, -1, -1]
% О -> [-1, +1, -1, -1]
% Н -> [-1, -1, +1, -1]
% Я -> [-1, -1, -1, +1]
patterns = [x1, x2, x3, x4];   % 35 x 4

targets = eye(4) * 2 - 1;

n = size(patterns, 1);  % 35 входів
m = 4;                  % 4 нейрони
letter_names = {'С', 'О', 'Н', 'Я'};

%% --- Алгоритм навчання Хебба ---
W = zeros(m, n);   % [4 x 35]
b = zeros(m, 1);   % зміщення [4 x 1]

for k = 1:4
    W = W + targets(:,k) * patterns(:,k)';
    b = b + targets(:,k);
end

fprintf('=== Матриця ваг сформована за правилом Хебба ===\n');
fprintf('Розмір W: %dx%d\n', size(W,1), size(W,2));

%% --- Функція активації (знак) ---
activate = @(s) sign(s) + (s==0).*(-1);  % sign, але 0 -> -1

%% --- Тестування на навчальних зображеннях ---
fprintf('\n=== Тест на навчальних зображеннях ===\n');
correct_train = 0;
for k = 1:4
    s     = W * patterns(:,k) + b;
    y_out = activate(s);
    [~, idx] = max(y_out);
    status = 'OK';
    if idx ~= k
        status = 'ПОМИЛКА';
    else
        correct_train = correct_train + 1;
    end
    fprintf('Вхід: %s -> Розпізнано: %s [%s]\n', ...
        letter_names{k}, letter_names{idx}, status);
end
fprintf('Точність на навчальній вибірці: %d/4 (%.0f%%)\n', ...
    correct_train, correct_train/4*100);

%% --- Тестування із зашумленими зображеннями ---
fprintf('\n=== Тест із зашумленими зображеннями ===\n');
rng(42);
noise_levels = [0.10, 0.20];
accuracy_noise = zeros(1, length(noise_levels));

for ni = 1:length(noise_levels)
    nl = noise_levels(ni);
    fprintf('\n--- Шум %.0f%% (%d пікселів перевернуто з 35) ---\n', ...
        nl*100, round(nl*n));
    correct = 0;
    for k = 1:4
        x_noisy  = patterns(:,k);
        n_flip   = round(nl * n);
        idx_flip = randperm(n, n_flip);
        x_noisy(idx_flip) = -x_noisy(idx_flip);
        s     = W * x_noisy + b;
        y_out = activate(s);
        [~, rec_idx] = max(y_out);
        status = 'OK';
        if rec_idx ~= k
            status = 'ПОМИЛКА';
        else
            correct = correct + 1;
        end
        fprintf('Оригінал: %s -> Розпізнано: %s [%s]\n', ...
            letter_names{k}, letter_names{rec_idx}, status);
    end
    accuracy_noise(ni) = correct/4*100;
    fprintf('Точність: %d/4 (%.0f%%)\n', correct, accuracy_noise(ni));
end

%% --- Графік 1: Навчальні зображення букв ---
figure('Name', 'Навчальні зображення букв С, О, Н, Я', ...
       'Position', [100 400 700 250]);
all_imgs = {S_img, O_img, N_img, Ya_img};
for i = 1:4
    subplot(1, 4, i);
    img_display = (all_imgs{i} + 1) / 2;
    imshow(img_display, 'InitialMagnification', 'fit');
    title(letter_names{i}, 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'XColor', 'none', 'YColor', 'none');
end
sgtitle('Навчальні зображення (7x5 сітка, білий = +1, чорний = -1)', 'FontSize', 12);

%% --- Графік 2: Матриці ваг нейронів ---
figure('Name', 'Матриці ваг нейронів', 'Position', [100 100 700 250]);
for i = 1:4
    subplot(1, 4, i);
    w_map = reshape(W(i,:), 7, 5);
    w_norm = (w_map - min(w_map(:))) / (max(w_map(:)) - min(w_map(:)));
    imshow(w_norm, 'InitialMagnification', 'fit');
    title(['Нейрон ' letter_names{i}], 'FontSize', 13);
    colorbar('southoutside');
    set(gca, 'XColor', 'none', 'YColor', 'none');
end
sgtitle('Матриці ваг мережі Хебба (С, О, Н, Я)', 'FontSize', 12);

%% --- Графік 3: Точність при різних рівнях шуму ---
figure('Name', 'Точність розпізнавання', 'Position', [820 400 400 280]);
bar_data = [100, accuracy_noise];
bar_labels = {'0%', '10%', '20%'};
bar(bar_data, 0.5, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'k');
set(gca, 'XTickLabel', bar_labels, 'FontSize', 12);
xlabel('Рівень шуму', 'FontSize', 12);
ylabel('Точність (%)', 'FontSize', 12);
title('Точність розпізнавання при різних рівнях шуму', 'FontSize', 11);
ylim([0 110]);
grid on; grid minor;
for i = 1:3
    text(i, bar_data(i)+3, sprintf('%.0f%%', bar_data(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
end

fprintf('\n=== Готово! ===\n');
