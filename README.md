# EPDraCor

EarlyPrint Drama Corpus

The TEI documents in this repository have been generated from a selection of
of dramatic works out of the EarlyPrint.org collection. This selection is
being maintained in the
[epdracor-sources repository](http://github.com/dracor-org/epdracor-sources).

The following modifications to the original documents have been made:

- markup for words (`<tei:w>`) and punctuation (`<tei:pc>`) has been removed
- Wikidata IDs for plays have been added (see [inde.xml](index.xml))
- Wikidata IDs for authors have been added (see [authors.xml](authors.xml))
- speakers have been identified and a list of characters is being added (see
  JSON files in [meta/speakers](meta/speakers/))
- ...

## Updating the corpus

### Prerequisites

The XSLT workflow depends on the following tools

- [saxon XSLT processor](https://www.saxonica.com/)
- [xmlformat XML document formatter](http://www.kitebird.com/software/xmlformat/xmlformat.html)

### XSLT Transformation

To update the entire corpus from the sources run the the `ep2dracor` script like
this (assuming you have cloned the `epdracor-sources` repo to the same parent
directory as `epdracor`):

```sh
./ep2dracor ../epdracor-sources/xml/*.xml
```

You can also update individual files, for instance:

```sh
./ep2dracor ../epdracor-sources/xml/A17872.xml
```

## Tooling

For scripting or reporting purposes you may want to obtain a simple list of
plays included in the corpus. There is a stylesheet to generate such lists from
the [index.xml](index.xml) file.

```sh
# convert index.xml to CSV
saxon -s:index.xml -xsl:list.xsl
# list all DraCor IDs
saxon -s:index.xml -xsl:list.xsl type=id
# list all DraCor slugs
saxon -s:index.xml -xsl:list.xsl type=slug
# list all original EarlyPrint IDs
saxon -s:index.xml -xsl:list.xsl type=sourceid
# list only "vanilla selection"
saxon -s:index.xml -xsl:list.xsl type=slug vanilla=yes
```
