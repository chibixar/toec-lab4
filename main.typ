#import "@preview/modern-g7-32:0.2.0": *
#import "@local/typst-bsuir-core:1.1.1": *
#import "@preview/zap:0.5.0"

#set text(font: "Times New Roman", size: 14pt)
#show math.equation: set text(font: "STIX Two Math", size: 14pt)

#show: gost.with(
  title-template: custom-title-template.from-module(toec-template),
  department: "Кафедра теоретических основ электротехники",
  work: (
    type: "Лабораторная работа",
    number: "4",
    subject: "Исследование резонанса в одиночных колебательных контурах",
    variant: "6",
  ),
  manager: (
    name: "Батюков С. В.",
  ),
  performer: (
    name: "Минкевич А. С.",
    group: "558301",
  ),
  footer: (city: "Минск", year: 2026),
  city: none,
  year: none,
  add-pagebreaks: false,
  text-size: 14pt,
)

#show: apply-toec-styling

// Принудительное выравнивание нумерации страниц по правому краю (ГОСТ)
#set page(footer: context align(right)[#counter(page).display()])

// ==========================================
// БЛОК ВЫЧИСЛЕНИЙ (на печать не выводится)
// ==========================================
// Данные для последовательного контура (Бригада 6)
#let V_ser = (
  U: 3.5,
  rk: 29.0,
  L: 224,
  C: 7.47,
  brigade: 6
)

#let L1_H = V_ser.L * 1e-3
#let C1_F = V_ser.C * 1e-6
#let f0_ser = 1 / (2 * calc.pi * calc.sqrt(L1_H * C1_F))
#let rho_ser = calc.sqrt(L1_H / C1_F)
#let Q_ser = rho_ser / V_ser.rk

// Данные для параллельного контура (Бригада 6)
#let V_par = (
  U: 29.5,
  C: 6.47,
  L: 398,
  rk: 41.0,
  Rd1: 5.6,
  Rd2: 9.0,
  brigade: 6
)

#let L2_H = V_par.L * 1e-3
#let C2_F = V_par.C * 1e-6
#let f0_par = 1 / (2 * calc.pi * calc.sqrt(L2_H * C2_F))
#let rho_par = calc.sqrt(L2_H / C2_F)
#let R0_par = calc.pow(rho_par, 2) / V_par.rk
#let Q_par = rho_par / V_par.rk

#let Rd1_ohm = V_par.Rd1 * 1000
#let Rd2_ohm = V_par.Rd2 * 1000

#let Q1_pr = Q_par / (1 + (R0_par / Rd1_ohm))
#let Q2_pr = Q_par / (1 + (R0_par / Rd2_ohm))

#let Uk0_1 = V_par.U * (R0_par / (R0_par + Rd1_ohm))
#let Uk0_2 = V_par.U * (R0_par / (R0_par + Rd2_ohm))

// Точные экспериментальные данные из таблицы 3 (f, I, Uc, Uk)
#let exp_data_ser = (
  (50, 10.0, 4.31, 0.88),
  (105, 69.0, 13.33, 10.56),
  (108, 75.9, 15.3, 12.8),
  (111, 89.2, 17.5, 15.5),
  (114, 102.1, 19.68, 18.55),
  (117, 111.8, 20.6, 20.2),
  (120, 112.3, 20.3, 21.0),
  (123.037, 105.0, 18.9, 20.0),
  (126, 95.2, 16.45, 18.72),
  (129, 83.0, 14.0, 16.69),
  (132, 72.8, 11.93, 14.86),
  (135, 69.3, 10.24, 13.37),
  (138, 57.2, 8.90, 12.18),
  (141, 51.5, 7.83, 11.13),
  (200, 17.9, 1.919, 5.41)
)

// ==========================================
// НАЧАЛО ДОКУМЕНТА
// ==========================================

= Цель работы
Экспериментальное исследование частотных и резонансных характеристик последовательного контура, влияния активного сопротивления на вид резонансных кривых. Ознакомление с настройкой последовательного контура на резонанс с помощью емкости. Изучение частотных свойств параллельного колебательного контура, снятие амплитудно-частотных и фазочастотных характеристик.

= Расчет домашнего задания

== Последовательный колебательный контур

Исходные данные варианта #V_ser.brigade представлены в таблице @src-table-1.

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      [Номер бригады], [$U_"ВХ"$, В], [$r_"k1"$, Ом], [$L_K$, мГн], [$C$, мкФ]
    ),
    [#V_ser.brigade], [#V_ser.U], [#V_ser.rk], [#V_ser.L], [#V_ser.C]
  ),
  caption: [Исходные данные для последовательного контура]
) <src-table-1>

Схема электрической цепи для последовательного соединения представлена на рисунке @src-circuit-1.

#lab-figure(
  above: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *
    node-better("1", (0, 4), visible: true)
    node-better("2", (12, 4), visible: true)
    node-better("3", (12, 0), visible: true)
    node-better("4", (0, 0), visible: true)

    open-branch-better("U_in", "1", "4", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")

    wire("1", (2,4))
    current-arrow("I", (2,4), (4,4), arrow-label: $dot(I)$, arrow-side: "top", arrow-dir: "forward")
    resistor-better("rk", (4,4), (8,4), label: (content: $r_"k1"$, anchor: "bottom"))
    inductor-better("L", (8,4), "2", label: (content: $L_K$, anchor: "bottom"))

    capacitor-better("C", "2", "3", label: (content: $C$, anchor: "left"), arrow-label: $dot(U)_C$, arrow-side: "right", arrow-dir: "down")

    wire("3", "4")
  }),
  caption: [Схема для исследования последовательного колебательного контура]
) <src-circuit-1>

Определим резонансную частоту $f_0$, характеристическое сопротивление $rho$ и добротность контура $Q$.
#mathtype-mimic(spacing: 1em)[
  $ f_0 &= 1 / (2 pi sqrt(L_K C)) = 1 / (2 dot pi dot sqrt(#V_ser.L dot 10^(-3) dot #V_ser.C dot 10^(-6))) = #f0_ser " Гц"; $
  $ rho &= sqrt(L_K / C) = sqrt((#V_ser.L dot 10^(-3)) / (#V_ser.C dot 10^(-6))) = #rho_ser " Ом"; $
  $ Q &= rho / r_"k1" = #rho_ser / #V_ser.rk = #Q_ser. $
]

Зависимости тока в цепи и напряжений на элементах контура от частоты описываются уравнениями:
#mathtype-mimic(spacing: 1em)[
  $ I(f) &= U / sqrt(r_"k1"^2 + (2 pi f L_K - 1 / (2 pi f C))^2); $
  $ U_C (f) &= I(f) dot 1 / (2 pi f C); $
  $ U_L (f) &= I(f) dot 2 pi f L_K. $
]

Расчет и построение резонансных кривых тока $I(f)$, напряжения на емкости $U_C (f)$ и напряжения на идеальной индуктивности $U_L (f)$ представлены на рисунке @mathcad-series.

#figure(
  image("mathcad/series.png", width: 100%),
  caption: [Резонансные кривые последовательного контура]
) <mathcad-series>

== Параллельный колебательный контур

Исходные данные для параллельного контура представлены в таблице @src-table-2.

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      [Вариант], [$C$, мкФ], [$U$, В], [$R_("д"1)$, кОм], [$R_("д"2)$, кОм], [$L_2$, мГн], [$r_"k2"$, Ом]
    ),
    [#V_par.brigade], [#V_par.C], [#V_par.U], [#V_par.Rd1], [#V_par.Rd2], [#V_par.L], [#V_par.rk]
  ),
  caption: [Исходные данные для параллельного контура]
) <src-table-2>

Схема электрической цепи для исследования резонанса токов представлена на рисунке @src-circuit-2.

#lab-figure(
  above: -1em,
  circuit-better(scale-factor: 80%, {
    import zap: *
    node-better("T_SRC", (0, 6), visible: true)
    node-better("B_SRC", (0, 0), visible: true)
    
    node-better("T_TANK", (6, 6), visible: true)
    node-better("B_TANK", (6, 0), visible: true)

    node-better("T_R", (10, 6), visible: false)
    node-better("M_R", (10, 3), visible: false)
    node-better("B_R", (10, 0), visible: false)

    open-branch-better("U_in", "T_SRC", "B_SRC", label: $dot(U)$, arrow-side: "left", arrow-dir: "down")
    resistor-better("Rd", "T_SRC", "T_TANK", label: (content: $R_"д"$, anchor: "bottom"))
    capacitor-better("C", "T_TANK", "B_TANK", label: (content: $C$, anchor: "left"))

    wire("T_TANK", "T_R")
    inductor-better("L", "T_R", "M_R", label: (content: $L_2$, anchor: "left"))
    resistor-better("rk", "M_R", "B_R", label: (content: $r_"k2"$, anchor: "left"))

    wire("B_R", "B_TANK")
    wire("B_TANK", "B_SRC")
  }),
  caption: [Схема для исследования параллельного колебательного контура]
) <src-circuit-2>

Рассчитаем параметры параллельного контура: резонансную частоту $f_0$, характеристическое сопротивление $rho$, эквивалентное сопротивление при резонансе $R_0$ и собственную добротность $Q$.

#mathtype-mimic(spacing: 1em)[
  $ f_0 &= 1 / (2 pi sqrt(L_2 C)) = 1 / (2 dot pi dot sqrt(#V_par.L dot 10^(-3) dot #V_par.C dot 10^(-6))) = #f0_par " Гц"; $
  $ rho &= sqrt(L_2 / C) = sqrt((#V_par.L dot 10^(-3)) / (#V_par.C dot 10^(-6))) = #rho_par " Ом"; $
  $ R_0 &= rho^2 / r_"k2" = (#rho_par)^2 / #V_par.rk = #R0_par " Ом"; $
  $ Q &= rho / r_"k2" = #rho_par / #V_par.rk = #Q_par. $
]

#[
#set par(spacing: 0.8em)
При наличии источника с внутренним (добавочным) сопротивлением $R_"д"$, добротность контура $Q'$ ухудшается. Рассчитаем эквивалентную добротность и напряжение на контуре при резонансе $U_"k0"$ для двух значений сопротивления: $R_("д1") = #_fmt(V_par.Rd1)$ кОм и $R_("д2") = #_fmt(V_par.Rd2)$ кОм.

Для $R_("д1")$:
#v(0.5em)
#mathtype-mimic(spacing: 1em)[
  $ Q'_1 &= Q / (1 + R_0 / R_("д1")) = #Q_par / (1 + #R0_par / #Rd1_ohm) = #Q1_pr ; $
  $ U_("k0"_1) &= U dot R_0 / (R_0 + R_("д1")) = #V_par.U dot #R0_par / (#R0_par + #Rd1_ohm) = #Uk0_1 " В". $
]

#unbreakable[
Для $R_("д2")$:
#mathtype-mimic(spacing: 1em)[
  $ Q'_2 &= Q / (1 + R_0 / R_("д2")) = #Q_par / (1 + #R0_par / #Rd2_ohm) = #Q2_pr ; $
  $ U_("k0"_2) &= U dot R_0 / (R_0 + R_("д2")) = #V_par.U dot #R0_par / (#R0_par + #Rd2_ohm) = #Uk0_2 " В". $
]
]
#v(0.5em)
Амплитудно-частотная $U_k (f)$ и фазочастотная $phi (f)$ характеристики контура определяются выражениями:
#mathtype-mimic(spacing: 1em)[
  $ U_k (f) = U_"k0" / sqrt(1 + (Q' (f / f_0 - f_0 / f))^2); $
  $ phi (f) = - "arctg" (Q' (f / f_0 - f_0 / f)). $
]
]
Результаты представлены на рисунке @mathcad-parallel.

#figure(
  image("mathcad/parallel.png", width: 100%),
  caption: [АЧХ и ФЧХ параллельного колебательного контура]
) <mathcad-parallel>

= Таблицы результатов измерений и расчетов

// ==========================================
// АВТОМАТИЧЕСКИЙ РАСЧЕТ ДЛЯ ПОСЛЕДОВАТЕЛЬНОГО КОНТУРА
// ==========================================
#let get_series_row(f) = {
  let w = 2 * calc.pi * f
  let XL = w * L1_H
  let XC = 1 / (w * C1_F)
  let Z = calc.sqrt(calc.pow(V_ser.rk, 2) + calc.pow(XL - XC, 2))
  let I = V_ser.U / Z
  let UC = I * XC
  let Uk = I * calc.sqrt(calc.pow(V_ser.rk, 2) + calc.pow(XL, 2))
  return (
    _fmt(I * 1000, digits: 3), 
    _fmt(UC, digits: 3), 
    _fmt(Uk, digits: 3)
  )
}

#let tbl_ser_content = ()

#for (i, row) in exp_data_ser.enumerate() {
  let f = row.at(0)
  if i == 0 { tbl_ser_content.push(table.cell(rowspan: 7)[До рез.]) }
  if i == 7 { tbl_ser_content.push(table.cell(rowspan: 1)[Рез.]) }
  if i == 8 { tbl_ser_content.push(table.cell(rowspan: 7)[После рез.]) }

  let f_fmt = if f == f0_ser { _fmt(f, digits: 3) } else { _fmt(f, digits: 0) }
  tbl_ser_content.push(f_fmt)

  let calc_row = get_series_row(f)

  tbl_ser_content.push(calc_row.at(0))
  tbl_ser_content.push(_fmt(row.at(1), digits: 1)) // I exp
  
  tbl_ser_content.push(calc_row.at(1))
  tbl_ser_content.push(_fmt(row.at(2), digits: 2)) // Uc exp
  
  tbl_ser_content.push(calc_row.at(2))
  tbl_ser_content.push(_fmt(row.at(3), digits: 2)) // Uk exp
}

#unbreakable[
#figure(
  table(
    columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[Режим],
      table.cell(rowspan: 2)[$f$, Гц],
      table.cell(colspan: 2)[$I$, мА],
      table.cell(colspan: 2)[$U_C$, В],
      table.cell(colspan: 2)[$U_k$, В],
      [Расчет], [Опыт], [Расчет], [Опыт], [Расчет], [Опыт]
    ),
    ..tbl_ser_content
  ),
  caption: [Резонансные характеристики последовательного контура]
) <res-table-series>
]

// ==========================================
// АВТОМАТИЧЕСКИЙ РАСЧЕТ ДЛЯ ПАРАЛЛЕЛЬНОГО КОНТУРА
// ==========================================
#let get_parallel_row(f) = {
  let detuning = f / f0_par - f0_par / f
  let Uk1 = Uk0_1 / calc.sqrt(1 + calc.pow(Q1_pr * detuning, 2))
  let phi1 = - calc.atan(Q1_pr * detuning).deg()

  let Uk2 = Uk0_2 / calc.sqrt(1 + calc.pow(Q2_pr * detuning, 2))
  let phi2 = - calc.atan(Q2_pr * detuning).deg()

  return (
    _fmt(Uk1, digits: 3), _fmt(phi1, digits: 3),
    _fmt(Uk2, digits: 3), _fmt(phi2, digits: 3)
  )
}

#let f0_p_int = calc.round(f0_par)
#let freqs_par = (50, f0_p_int - 18, f0_p_int - 15, f0_p_int - 12, f0_p_int - 9, f0_p_int - 6, f0_p_int - 3, f0_par, f0_p_int + 3, f0_p_int + 6, f0_p_int + 9, f0_p_int + 12, f0_p_int + 15, f0_p_int + 18, 180)
#let tbl_par_content = ()

#for (i, f) in freqs_par.enumerate() {
  if i == 0 { tbl_par_content.push(table.cell(rowspan: 7)[До рез.]) }
  if i == 7 { tbl_par_content.push(table.cell(rowspan: 1)[Рез.]) }
  if i == 8 { tbl_par_content.push(table.cell(rowspan: 7)[После рез.]) }

  let f_fmt = if f == f0_par { _fmt(f, digits: 3) } else { _fmt(f, digits: 0) }
  tbl_par_content.push(f_fmt)

  let row_calc = get_parallel_row(f)
  
  // Uk1 Расчет и Опыт (Опыт оставлен пустым по методике)
  tbl_par_content.push(row_calc.at(0))
  tbl_par_content.push([])
  
  // phi1 Расчет и Опыт
  tbl_par_content.push(row_calc.at(1))
  tbl_par_content.push([])
  
  // Uk2 Расчет и Опыт
  tbl_par_content.push(row_calc.at(2))
  tbl_par_content.push([])
  
  // phi2 Расчет и Опыт
  tbl_par_content.push(row_calc.at(3))
  tbl_par_content.push([])
}

#unbreakable[
#figure(
  table(
    columns: (3em, 3em, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 3)[Режим],
      table.cell(rowspan: 3)[$f$, Гц],
      table.cell(colspan: 4)[При $R_"д1" = #_fmt(V_par.Rd1)$ кОм],
      table.cell(colspan: 4)[При $R_"д2" = #_fmt(V_par.Rd2)$ кОм],

      table.cell(colspan: 2)[$U_k$, В], table.cell(colspan: 2)[$phi$, град.],
      table.cell(colspan: 2)[$U_k$, В], table.cell(colspan: 2)[$phi$, град.],

      [Расч.], [Опыт], [Расч.], [Опыт], [Расч.], [Опыт], [Расч.], [Опыт]
    ),
    ..tbl_par_content
  ),
  caption: [Характеристики параллельного контура]
) <res-table-parallel>
]

#pagebreak()
= Обработка экспериментальных данных

По полученным экспериментальным данным построим векторные диаграммы токов и напряжений для частот $f < f_0$, $f = f_0$, $f > f_0$:

#let draw_vec(f, cap) = {
  let w = 2 * calc.pi * f
  let XL = w * L1_H
  let XC = 1 / (w * C1_F)
  let Z = calc.sqrt(V_ser.rk * V_ser.rk + calc.pow(XL - XC, 2))
  let I = V_ser.U / Z
  let Ur = I * V_ser.rk
  let UL = I * XL
  let UC = I * XC
  
  figure(
    align(center, zap.cetz.canvas({
      import zap.cetz.draw: *
      let su = 0.5   // Увеличенный масштаб для напряжений
      let si = 50    // Увеличенный масштаб для тока
      
      // Динамический расчет осей чтобы они всегда вмещали векторы
      let y_max = calc.max(UL * su, 1.0) + 1.0
      let y_min = calc.min((UL - UC) * su, -1.0) - 1.0
      let x_max = calc.max(Ur * su, I * si) + 1.5
      
      // Оси
      line((0, y_min), (0, y_max), mark: (end: "stealth"), stroke: 0.5pt+gray)
      content((0.4, y_max - 0.2), [$+j$])
      line((-1, 0), (x_max, 0), mark: (end: "stealth"), stroke: 0.5pt+gray)
      content((x_max - 0.2, -0.4), [$+1$])
      
      // Вектор Ur
      line((0,0), (Ur*su, 0), mark: (end: "stealth", fill: black), stroke: 1.2pt+black)
      content((Ur*su/2, -0.4), [$U_r$])
      
      // Вектор UL
      line((Ur*su, 0), (Ur*su, UL*su), mark: (end: "stealth", fill: black), stroke: 1.2pt+black)
      content((Ur*su + 0.5, UL*su/2), [$U_L$])
      
      // Вектор UC
      line((Ur*su, UL*su), (Ur*su, (UL - UC)*su), mark: (end: "stealth", fill: black), stroke: 1.2pt+black)
      content((Ur*su - 0.6, UL*su - UC*su/2), [$U_C$])
      
      // Вектор суммарного U
      line((0,0), (Ur*su, (UL - UC)*su), mark: (end: "stealth", fill: black), stroke: 1.2pt+black)
      content((Ur*su/2 - 0.4, (UL - UC)*su/2 + 0.4), [$U$])
      
      // Вектор I (выделен синим, чтобы отличался от Ur)
      line((0,0), (I*si, 0), mark: (end: "stealth", fill: rgb("1d3557")), stroke: 1.2pt+rgb("1d3557"))
      content((I*si + 0.3, 0.4), text(fill: rgb("1d3557"))[$I$])
    })),
    caption: cap
  )
}

#draw_vec(105, "Для частоты f = 105 Гц < f0 (рис. 5)")
#draw_vec(123, "Для частоты f = 123 Гц = f0 (рис. 6)")
#draw_vec(141, "Для частоты f = 141 Гц > f0 (рис. 7)")

По полученным экспериментальным данным построим частотные характеристики (рис. 8):

#figure(
  align(center, zap.cetz.canvas({
    import zap.cetz.draw: *
    let w = 12
    let h = 8
    let f_min = 0
    let f_max = 250
    
    // Функции маппинга
    let mx(f) = (f - f_min)/(f_max - f_min) * w
    let my(v) = v / 500 * h 
    
    // Внешняя рамка
    rect((0,0), (w, h), stroke: 0.5pt+black)
    
    // Риски по оси X
    for f in (0, 100, 200) {
      line((mx(f), 0), (mx(f), 0.15))
      content((mx(f), -0.4), str(f))
    }
    content((mx(123), -0.4), [$f_0$])
    line((mx(123), 0), (mx(123), h), stroke: 0.5pt+black)
    content((w/2, -1.0), [$f$])
    
    // Риски по оси Y
    for v in (100, 200, 300, 400) {
      line((0, my(v)), (0.15, my(v)))
      content((-0.6, my(v)), str(v))
    }
    
    // Генерация точек
    let pts_xl = ()
    let pts_xc = ()
    let pts_z = ()
    
    for f in range(10, 251, step: 2) {
      let xl = 2 * calc.pi * f * L1_H
      let xc = 1 / (2 * calc.pi * f * C1_F)
      let z = calc.sqrt(V_ser.rk * V_ser.rk + calc.pow(xl - xc, 2))
      
      if my(xl) <= h { pts_xl.push((mx(f), my(xl))) }
      if my(xc) <= h { pts_xc.push((mx(f), my(xc))) }
      if my(z) <= h { pts_z.push((mx(f), my(z))) }
    }
    
    // Отрисовка линий согласно заданию (X_C красная, Z синяя из точек, X_L зеленая штриховая)
    line(..pts_xl, stroke: (paint: rgb("00aa00"), thickness: 1.5pt, dash: "dashed"))
    line(..pts_xc, stroke: 1.5pt + rgb("aa0000"))
    line(..pts_z,  stroke: (paint: rgb("0000aa"), thickness: 1.5pt, dash: (1pt, 3pt), cap: "round"))
    
    // Метки графиков
    content((-1.0, my(300)), text(fill: rgb("aa0000"))[$X_C(f)$])
    content((-1.0, my(260)), text(fill: rgb("0000aa"))[$Z(f)$])
    content((-1.0, my(220)), text(fill: rgb("00aa00"))[$X_L(f)$])
    
    // Линия активного сопротивления r
    line((0, my(V_ser.rk)), (w, my(V_ser.rk)), stroke: 0.5pt + gray, dash: "dashed")
    content((-0.4, my(V_ser.rk)), [$r$])
    
  })),
  caption: [Частотные характеристики]
)

Из графика находим: $f_0 approx 123$ Гц;

Сопротивления емкости и индуктивности на резонансной частоте равны характеристическому сопротивлению контура, тогда:
#mathtype-mimic(spacing: 1em)[
  $ rho = 2 pi f_0 L = 1 / (2 pi f_0 C) = 1 / (2 dot pi dot 123 dot 7.47 dot 10^(-6)) = 173.166 " Ом"; $
]

По данным из табл. 3 построим резонансные кривые тока и напряжений (рис. 9).

#figure(
  align(center, zap.cetz.canvas({
    import zap.cetz.draw: *
    
    let w = 15
    let h = 8
    let f_min = 40
    let f_max = 210
    let i_max = 120
    let u_max = 26

    let map_x(f) = (f - f_min) / (f_max - f_min) * w
    let map_i(i) = i / i_max * h
    let map_u(u) = u / u_max * h

    // Сетка и подписи
    for i in range(0, 121, step: 10) {
      line((0, map_i(i)), (w, map_i(i)), stroke: luma(220) + 0.5pt)
      content((-0.5, map_i(i)), text(size: 8pt)[#i])
    }
    for f in range(45, 220, step: 15) {
      line((map_x(f), 0), (map_x(f), h), stroke: luma(220) + 0.5pt)
      content((map_x(f), -0.4), text(size: 8pt)[#f])
    }

    // Оси
    line((0, 0), (w, 0))
    line((0, 0), (0, h))

    // Точки экспериментальных данных (табл.3)
    let pts_i = ()
    let pts_uc = ()
    let pts_uk = ()
    
    for row in exp_data_ser {
      let f = row.at(0)
      pts_i.push((map_x(f), map_i(row.at(1))))
      pts_uc.push((map_x(f), map_u(row.at(2))))
      pts_uk.push((map_x(f), map_u(row.at(3))))
    }

    // Линии сплайнами (catmull)
    catmull(..pts_i, stroke: 1.5pt + rgb("21618C")) 
    catmull(..pts_uc, stroke: 1.5pt + rgb("C0392B"))
    catmull(..pts_uk, stroke: 1.5pt + rgb("AF7AC5"))

    // Точки на графике
    for p in pts_i { circle(p, radius: 0.05, fill: rgb("21618C")) }
    for p in pts_uc { circle(p, radius: 0.05, fill: rgb("C0392B")) }
    for p in pts_uk { circle(p, radius: 0.05, fill: rgb("AF7AC5")) }

    // Разметка I0, I0/sqrt(2), f1, f0, f2
    let i0 = 112.3
    let f0 = 120
    let i_0707 = i0 / calc.sqrt(2) // ~79.4
    let f1 = 109 // интерполяция 108(75.9) - 111(89.2)
    let f2 = 130 // интерполяция 129(83.0) - 132(72.8)

    line((0, map_i(i0)), (map_x(f0), map_i(i0)), stroke: 1pt + black)
    line((0, map_i(i_0707)), (map_x(f2), map_i(i_0707)), stroke: 1pt + black)
    
    line((map_x(f0), 0), (map_x(f0), map_i(i0)), stroke: 1pt + black)
    line((map_x(f1), 0), (map_x(f1), map_i(i_0707)), stroke: 1pt + black)
    line((map_x(f2), 0), (map_x(f2), map_i(i_0707)), stroke: 1pt + black)

    content((-0.8, map_i(i0)), [$I_0$])
    content((-0.8, map_i(i_0707)), [$I_0/sqrt(2)$])
    
    content((map_x(f0)-0.3, 0.4), [$f_0$])
    content((map_x(f1)-0.3, 0.4), [$f_1$])
    content((map_x(f2)+0.3, 0.4), [$f_2$])
    
    content((map_x(160), map_i(45)), text(fill: rgb("21618C"))[$I(f)$])
    content((map_x(160), map_u(16)), text(fill: rgb("C0392B"))[$U_C(f)$])
    content((map_x(160), map_u(12)), text(fill: rgb("AF7AC5"))[$U_k(f)$])
    
  })),
  caption: [Полученные экспериментально резонансные кривые тока и напряжений]
) <fig-exp-resonance>

По данным с резонансных характеристик (рис. 9) определим добротность последовательного контура:
#mathtype-mimic(spacing: 1em)[
  $ Q = f_0 / (f_2 - f_1) = 120 / (130 - 109) approx 5.71; $
]

Определим добротность другими способами, и сравним результаты:
#mathtype-mimic(spacing: 1em)[
  $ Q = rho / r_"k1" = 173.166 / 29 approx 5.97; $
  $ Q = U_"C0" / U_"вх" = 20.3 / 3.5 approx 5.80; $
  $ Q = U_"k0" / U_"вх" = 21.0 / 3.5 = 6.00. $
]

Вычислим параметры для параллельного колебательного контура:
а) Характеристическое сопротивление контура:
#mathtype-mimic(spacing: 1em)[
  $ rho = sqrt(L_2 / C) = sqrt((#V_par.L dot 10^(-3)) / (#V_par.C dot 10^(-6))) = #rho_par " Ом"; $
]
б) Сопротивление контура $R_0$ при резонансе:
#mathtype-mimic(spacing: 1em)[
  $ R_0 = rho^2 / r_"k2" = (#rho_par)^2 / #V_par.rk = #R0_par " Ом"; $
]
в) Добротность контура по резонансной характеристике при двух значениях $R_"д"$:
#mathtype-mimic(spacing: 1em)[
  $ Q'_1 &= Q / (1 + R_0 / R_("д1")) = #Q_par / (1 + #R0_par / #Rd1_ohm) = #Q1_pr ; $
  $ Q'_2 &= Q / (1 + R_0 / R_("д2")) = #Q_par / (1 + #R0_par / #Rd2_ohm) = #Q2_pr . $
]

== Вывод:
В результате выполненной работы были теоретически рассчитаны и экспериментально подтверждены частотные и резонансные характеристики последовательного и параллельного колебательных контуров. Данные, полученные экспериментально, оказались близкими к расчётным. Смещение частоты резонанса в практическом опыте связано с неидеальностью элементов схемы и внутренним сопротивлением генератора. Также рассчитали добротность контура разными способами. Небольшую разницу в значениях можно объяснить инструментальной погрешностью измерительных приборов. Были построены наглядные резонансные кривые тока и напряжений, подтверждающие теоретические основы резонансных цепей переменного тока.