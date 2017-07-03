# Jekyll-Quicklatex

Jekyll-Quicklatex is a converter plugin for Jekyll. It convert latex code
snippet to picture embeded in your page.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll-quicklatex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-quicklatex

## Usage

for example, we use package tikz to describe a picture

```
{% latex %}
{% highlight latex %}
\usepackage{tikz}
\begin{tikzpicture}[scale=3]
  \tikzset{Karl's grid/.style ={help lines,color=#1!50},
    Karl's grid/.default=blue}

  \clip (-0.1,-0.2) rectangle (1.1,1.51);

  \draw[step=.5cm,Karl's grid] (-1.4,-1.4) grid (1.4,1.4);
  \draw[->] (-1.5,0) -- (1.5,0);
  \draw[->] (0, -1.5) -- (0,1.5);
  \draw (0,0) circle [radius=1cm];
  \shadedraw[left color=gray, right color=green, draw=green!50!black] (0,0) -- (3mm,0mm)
    arc [start angle=0, end angle=30, radius=3mm] -- cycle;

  \draw[red,very thick] (30:1cm) -- +(0,-0.5);
  \draw[blue,very thick] (30:1cm) ++(0,-0.5) -- (0,0);
  \draw[orange,very thick] (1,0) -- (1, {tan(30)});

  \foreach \x in {-1cm,-0.5cm,1cm}
  \draw (\x,-1pt) -- (\x,1pt);
  \foreach \y in {-1cm,-0.5cm,0.5cm,1cm}
  \draw (-1pt,\y) -- (1pt,\y);
\end{tikzpicture}
{% endhighlight %}
{% endlatex %}
```

it'll render the img and show its source below!

[see result here: learn tikz by examples][tikz]

## Strategy

This plugin visit [quicklatex][quicklatex] to compile code snippet into
picture, then fetch the picture back into `./assets/latex` directory, and
render a `<img>` on your page.

At the same time, it'll write new file named `latex.cache` to avoid recompile
the snippet again. If you want to recompile all the snippets, delete
`latex.cache` first.

**WARNING** below

The process of fetching picture back is after copy assets into _site
directory when `jekyll build`. So after first build, pictures are fetched but
not in _site/. If you build again, everything's fine. That's the way I
recommend.

In this plugin, I use the stratery that adding a fallback quicklatex
link for every <img>s. So if local picture is not found, it'll fetch remote
picture automatically. **Pay attention**, link in quicklatex has a expire time,
so don't rely on this stratery.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[tikz]: http://dreamanddead.github.io/2017/03/25/learn-tikz-by-examples.html
