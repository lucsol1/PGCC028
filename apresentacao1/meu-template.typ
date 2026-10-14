// ==========================================================================
// meu-template.typ
// Template de slides personalizado, baseado em @preview/typslides
// (https://github.com/manjavacas/typslides), com as seguintes adições:
//
//   1. Fundo do slide totalmente customizável: cor sólida (back-color) OU
//      imagem de fundo (back-image), tanto globalmente quanto por slide.
//   2. "Kicker" (título) no topo do slide, na mesma faixa onde fica a
//      numeração de página — aparece em TODOS os slides, mesmo os que não
//      recebem um `title:` explícito, mostrando o nome da seção atual.
//   3. Capa (front-slide) com data atual preenchida automaticamente,
//      formatada em português (ex.: "14 de agosto de 2026").
//
// Este arquivo é independente: não depende do pacote @preview/typslides,
// então você pode editar cores, tipografia e layout livremente.
// ==========================================================================

//************************************************************************\\
// Paleta de cores (igual à do typslides original)                        \\
//************************************************************************\\

#let _theme-colors = (
  bluey: rgb("3059AB"),
  reddy: rgb("BF3D3D"),
  greeny: rgb("28842F"),
  yelly: rgb("C4853D"),
  purply: rgb("862A70"),
  dusky: rgb("1F4289"),
  darky: black,
)

#let bluey(body) = text(fill: rgb("3059AB"))[#body]
#let greeny(body) = text(fill: rgb("28842F"))[#body]
#let reddy(body) = text(fill: rgb("BF3D3D"))[#body]
#let yelly(body) = text(fill: rgb("C4853D"))[#body]
#let purply(body) = text(fill: rgb("862A70"))[#body]
#let dusky(body) = text(fill: rgb("1F4289"))[#body]

//************************************************************************\\
// Estado global                                                          \\
//************************************************************************\\

#let theme-color = state("theme-color", none)
#let default-back-color = state("default-back-color", white)
// NOVO: imagem de fundo padrão (caminho para o arquivo), aplicada em todo
// slide que não definir a sua própria back-image.
#let default-back-image = state("default-back-image", none)
#let sections = state("sections", ())
#let page-numbers = state("show-page-numbers", true)
#let progress-enabled = state("show-progress", false)
#let progress-thickness = state("progress-thickness", 3pt)
// NOVO: guarda o nome da seção/título atual, para exibir como "kicker"
// no topo dos slides que não têm título próprio.
#let current-section = state("current-section", "")
// NOVO: liga/desliga o kicker globalmente.
#let kicker-enabled = state("kicker-enabled", true)

//************************************************************************\\
// Utilitários internos                                                   \\
//************************************************************************\\

#let _resize-text(body) = layout(size => {
  let font-size = text.size
  let (height,) = measure(
    block(width: size.width, text(size: font-size)[#body]),
  )
  let max_height = size.height
  while height > max_height {
    font-size -= 0.2pt
    height = measure(
      block(width: size.width, text(size: font-size)[#body]),
    ).height
  }
  block(
    height: height,
    width: 100%,
    text(size: font-size)[#body],
  )
})

#let _divider(color: none) = {
  line(length: 100%, stroke: 2.5pt + color)
}

#let _progress-divider(color: none) = context {
  let current = counter(page).get().first()
  let total = counter(page).final().first()
  let progress-width = if total == 0 { 0% } else { (current / total) * 100% }
  stack(
    dir: ltr,
    rect(width: progress-width, height: 2.5pt, fill: color, radius: 0pt),
    rect(width: 100% - progress-width, height: 2.5pt, fill: color.lighten(60%), radius: 0pt),
  )
}

#let _progress-bar(color: black, height: 3pt) = context {
  let current = counter(page).get().first()
  let total = counter(page).final().first()
  let progress-width = if total == 0 { 0% } else { (current / total) * 100% }
  place(bottom + left, rect(width: 100%, height: height, fill: rgb(200, 200, 200, 25%)))
  place(bottom + left, rect(width: progress-width, height: height, fill: color))
}

// NOVO: coloca uma imagem cobrindo 100% do slide, usada como plano de fundo.
#let _background-image(img) = {
  if img != none {
    place(top + left, image(img, width: 100%, height: 100%, fit: "cover"))
  }
}

// NOVO: formata uma data em português por extenso (ex: 14 de agosto de 2026).
#let _meses-pt = (
  "janeiro", "fevereiro", "março", "abril", "maio", "junho",
  "julho", "agosto", "setembro", "outubro", "novembro", "dezembro",
)
#let formatar-data-pt(date) = {
  let d = date.day()
  let m = _meses-pt.at(date.month() - 1)
  let y = date.year()
  str(d) + " de " + m + " de " + str(y)
}

// Cabeçalho colorido no topo do slide (título + número de página).
// NOVO: se não houver título explícito mas houver "kicker" (seção atual)
// habilitado, mostra o nome da seção em vez de ficar vazio — assim TODO
// slide passa a ter uma faixa superior com numeração + contexto.
#let _slide-header(title, outlined, color, page-num: none, kicker: none) = {
  let shown-title = if title != none { title } else { kicker }
  let header-height = if shown-title != none { 1.6cm } else { .95cm }
  rect(
    fill: color,
    width: 100%,
    height: header-height,
    inset: .6cm,
    if outlined {
      grid(
        columns: (1fr, auto),
        align: (left, right),
        text(white, weight: "semibold", size: 24pt)[
          #h(.1cm) #title #metadata(title) <subsection>
        ],
        if page-num != none { text(white, weight: "semibold", size: 12pt)[#page-num] },
      )
    } else if shown-title != none {
      grid(
        columns: (1fr, auto),
        align: (left, right),
        text(white, weight: if title != none { "semibold" } else { "regular" }, size: if title != none { 24pt } else { 18pt })[
          #h(.1cm) #shown-title
        ],
        if page-num != none { text(white, weight: "semibold", size: 12pt)[#page-num] },
      )
    },
  )
}

#let _get-page-number() = context {
  if page-numbers.get() {
    counter(page).display("1 / 1", both: true)
  } else {
    none
  }
}

#let _get-progress-foreground(color: none) = context {
  if progress-enabled.get() {
    let bar-color = if color != none { color } else { theme-color.get() }
    _progress-bar(color: bar-color, height: progress-thickness.get())
  } else {
    none
  }
}

#let _apply-slide-text-styles() = {
  set list(marker: context text(theme-color.get(), [•]))
  set enum(numbering: (it => context text(fill: theme-color.get())[*#it.*]))
  set text(size: 20pt)
  set par(justify: true)
}

#let _make-frontpage(title, subtitle, authors, info, theme-color, margin) = {
  set align(left + horizon)
  set page(footer: none, margin: margin)
  text(40pt, weight: "bold")[#smallcaps(title)]
  v(-.95cm)
  if subtitle != none {
    set text(24pt)
    v(.1cm)
    subtitle
  }
  let subtext = ()
  if authors != none {
    subtext.push(text(22pt, weight: "regular")[#authors])
  }
  if info != none {
    subtext.push(text(20pt, fill: theme-color, weight: "regular")[#v(-.15cm) #info])
  }
  _divider(color: theme-color)
  subtext.join()
}

//************************************************************************\\
// Configuração principal                                                 \\
//************************************************************************\\

// ratio, theme, font, font-size, link-style: como no typslides original.
// back-color: cor de fundo padrão de todos os slides.
// back-image: NOVO — imagem de fundo padrão de todos os slides (caminho).
#let meu-template(
  ratio: "16-9",
  theme: "bluey",
  font: "Fira Sans",
  font-size: 21pt,
  link-style: "color",
  show-page-numbers: true,
  show-progress: false,
  progress-height: 3pt,
  back-color: white,
  back-image: none,
  show-kicker: true,
  body,
) = {
  page-numbers.update(show-page-numbers)
  progress-enabled.update(show-progress)
  progress-thickness.update(progress-height)
  default-back-color.update(back-color)
  default-back-image.update(back-image)
  kicker-enabled.update(show-kicker)

  if type(theme) == str {
    theme-color.update(_theme-colors.at(theme))
  } else {
    theme-color.update(theme)
  }

  set text(font: font, size: font-size)
  set page(paper: "presentation-" + ratio, fill: back-color)

  show ref: it => context text(fill: theme-color.get())[#it]
  show link: it => context {
    if it.has("label") {
      text(fill: theme-color.get())[#it]
    } else if link-style == "underline" {
      underline(stroke: theme-color.get())[#it]
    } else if link-style == "both" {
      text(fill: theme-color.get(), underline[#it])
    } else {
      text(fill: theme-color.get())[#it]
    }
  }
  show footnote: it => context text(fill: theme-color.get())[#it]
  set enum(numbering: (it => context text(fill: black)[*#it.*]))

  body
}

//************************************************************************\\
// Estilo de texto auxiliar                                               \\
//************************************************************************\\

#let themey(body) = context text(fill: theme-color.get())[#body]
#let stress(body) = context text(fill: theme-color.get(), weight: "semibold")[#body]

// Título auxiliar dentro do corpo de um #slide[...] (não é o `title:` do
// cabeçalho colorido — é um subtítulo dentro do conteúdo do slide).
#let title(body) = context [
  #text(size: 26pt, weight: "semibold", fill: theme-color.get())[#body]
  #v(-.2cm)
]

#let framed(title: none, back-color: none, content) = context {
  set block(inset: (x: .6cm, y: .6cm), breakable: false, above: .7cm, below: .7cm)
  let default-back = if title != none { white } else { rgb("FBF7EE") }
  let fill-color = if back-color != none { back-color } else { default-back }
  if title != none {
    set block(width: 100%)
    stack(
      block(fill: theme-color.get(), inset: (x: .6cm, y: .55cm), radius: (top: .2cm, bottom: 0cm), stroke: 2pt)[
        #text(weight: "semibold", fill: white)[#title]
      ],
      block(fill: fill-color, radius: (top: 0cm, bottom: .2cm), stroke: 2pt, content),
    )
  } else {
    block(width: auto, fill: fill-color, radius: .2cm, stroke: 2pt, content)
  }
}

#let cols(columns: none, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()
  let columns = if columns == none { (1fr,) * bodies.len() } else { columns }
  if columns.len() != bodies.len() {
    panic("O número de colunas deve ser igual ao número de conteúdos")
  }
  grid(columns: columns, gutter: gutter, ..bodies)
}

#let grayed(text-size: 24pt, fill-color: rgb("#F3F2F0"), content) = {
  set align(center + horizon)
  set text(size: text-size)
  block(fill: fill-color, inset: (x: .8cm, y: .8cm), breakable: false, above: .9cm, below: .9cm, radius: (top: .2cm, bottom: .2cm))[#content]
}

#let register-section(name) = context {
  let sect-page = here().position()
  sections.update(sections => {
    sections.push((body: name, loc: sect-page))
    sections
  })
}

//************************************************************************\\
// Capa (front-slide) — com data automática                               \\
//************************************************************************\\

// title, subtitle, authors: como no original.
// info: informação extra (ex.: link do repositório, instituição).
// date: NOVO — data exibida na capa. `auto` = hoje (formatada em pt-BR).
//       Passe `date: none` para omitir a data, ou uma string sua própria.
// back-color / back-image: fundo da capa (sobrepõe o padrão global).
#let front-slide(
  title: none,
  subtitle: none,
  authors: none,
  info: none,
  date: auto,
  back-color: none,
  back-image: none,
  margin: auto,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let bg-image = if back-image != none { back-image } else { default-back-image.get() }

  let data-mostrada = if date == auto {
    formatar-data-pt(datetime.today())
  } else if date == none {
    none
  } else {
    date
  }

  let info-final = if data-mostrada != none {
    if info != none {
      [#info #linebreak() #text(weight: "regular")[#data-mostrada]]
    } else {
      text(weight: "regular")[#data-mostrada]
    }
  } else {
    info
  }

  set page(fill: bg-color, background: _background-image(bg-image))
  _make-frontpage(title, subtitle, authors, info-final, theme-color.get(), margin)
}

//************************************************************************\\
// Sumário                                                                 \\
//************************************************************************\\

#let table-of-contents(title: "Sumário", text-size: 23pt, back-color: none, back-image: none) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let bg-image = if back-image != none { back-image } else { default-back-image.get() }
  set page(fill: bg-color, background: _background-image(bg-image))
  text(size: 42pt, weight: "bold")[
    #smallcaps(title)
    #v(-.9cm)
    #_progress-divider(color: theme-color.get())
  ]
  set text(size: text-size)
  show linebreak: none
  let secs = query(<section>).dedup()
  if secs.len() == 0 {
    let subsections = query(<subsection>).dedup()
    pad(enum(..subsections.map(sub => [#link(sub.location(), sub.value) <toc>])))
  } else {
    pad(enum(..secs.map(section => {
      let section-loc = section.location()
      let subsections = query(
        selector(<subsection>).after(section-loc).before(selector(<section>).after(section-loc, inclusive: false)),
      ).dedup()
      if subsections.len() != 0 {
        [#link(section-loc, section.value) <toc> #list(..subsections.map(sub => [#link(sub.location(), sub.value) <toc>]))]
      } else {
        [#link(section-loc, section.value) <toc>]
      }
    })))
  }
  pagebreak()
}

//************************************************************************\\
// Slide de seção (title-slide) — também memoriza o nome para o "kicker"   \\
//************************************************************************\\

#let title-slide(body, text-size: 42pt, back-color: none, back-image: none) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let bg-image = if back-image != none { back-image } else { default-back-image.get() }
  current-section.update(body) // NOVO: memoriza a seção para os slides seguintes
  set page(fill: bg-color, background: _background-image(bg-image))
  register-section(body)
  show heading: text.with(size: text-size, weight: "semibold")
  set align(left + horizon)
  [#heading(depth: 1, smallcaps(body)) #metadata(body) <section>]
  _progress-divider(color: theme-color.get())
  pagebreak()
}

//************************************************************************\\
// Focus slide                                                            \\
//************************************************************************\\

#let focus-slide(text-color: white, text-size: 60pt, back-color: none, back-image: none, body) = context {
  let bg-color = if back-color != none { back-color } else { theme-color.get() }
  let bg-image = back-image
  set page(
    fill: bg-color,
    background: _background-image(bg-image),
    foreground: _get-progress-foreground(color: white),
  )
  set text(weight: "semibold", size: text-size, fill: text-color)
  set align(center + horizon)
  _resize-text(body)
}

//************************************************************************\\
// Slide de conteúdo — fundo customizável + "kicker" de seção              \\
//************************************************************************\\

// title: título deste slide específico (aparece na faixa colorida do topo).
// kicker: controla o texto mostrado no topo quando `title` não é passado.
//         `auto` (padrão) = usa o nome da última seção (title-slide);
//         passe uma string para um texto fixo, ou `none` para não mostrar nada.
// back-color / back-image: sobrepõem o fundo padrão só para este slide.
// outlined: como no original, inclui este slide no sumário.
#let slide(
  title: none,
  kicker: auto,
  back-color: none,
  back-image: none,
  outlined: false,
  margin: none,
  body,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let bg-image = if back-image != none { back-image } else { default-back-image.get() }
  let page-num = _get-page-number()

  let kicker-shown = if not kicker-enabled.get() {
    none
  } else if kicker == auto {
    let sec = current-section.get()
    if sec != "" { sec } else { none }
  } else {
    kicker
  }

  set page(
    fill: bg-color,
    header-ascent: if title != none or kicker-shown != none { 65% } else { 66% },
    header: [],
    margin: if margin != none {
      margin
    } else if title != none or kicker-shown != none {
      (x: 1.6cm, top: 2.5cm, bottom: 1.2cm)
    } else {
      (x: 1.6cm, top: 1.75cm, bottom: 1.2cm)
    },
    background: {
      _background-image(bg-image)
      place(_slide-header(
        title,
        outlined,
        theme-color.get(),
        page-num: if title != none or kicker-shown != none { page-num } else { none },
        kicker: kicker-shown,
      ))
      if page-num != none and title == none and kicker-shown == none {
        place(top + right, box(inset: (right: 0.6cm, top: 0.325cm), text(fill: white, weight: "semibold", size: 12pt)[#page-num]))
      }
    },
    foreground: _get-progress-foreground(),
  )
  _apply-slide-text-styles()
  set align(horizon)
  v(0cm)
  body
}

//************************************************************************\\
// Slide em branco (sem cabeçalho)                                        \\
//************************************************************************\\

#let blank-slide(back-color: none, back-image: none, body) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let bg-image = if back-image != none { back-image } else { default-back-image.get() }
  let page-num = _get-page-number()
  set page(
    fill: bg-color,
    background: {
      _background-image(bg-image)
      if page-num != none {
        place(top + right, box(inset: (right: 0.6cm, top: 0.6cm), text(fill: theme-color.get(), weight: "semibold", size: 12pt)[#page-num]))
      }
    },
    foreground: _get-progress-foreground(),
  )
  _apply-slide-text-styles()
  set align(horizon)
  body
}

//************************************************************************\\
// Bibliografia                                                            \\
//************************************************************************\\

#let bibliography-slide(bib-call, title: "Referências", back-color: none, back-image: none) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let bg-image = if back-image != none { back-image } else { default-back-image.get() }
  set page(fill: bg-color, background: _background-image(bg-image))
  set text(size: 19pt)
  set par(justify: true)
  set bibliography(title: text(size: 30pt)[
    #smallcaps(title)
    #v(-.85cm)
    #_progress-divider(color: theme-color.get())
    #v(.5cm)
  ])
  bib-call
}
