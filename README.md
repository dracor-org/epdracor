# EPDraCor

__Note:__ *This corpus is still in __beta__ status.*

The EarlyPrint Drama Corpus (EPDraCor) provides TEI documents which have been
generated from a selection of dramatic works out of the EarlyPrint.org
collection. This selection is being maintained in the
[epdracor-sources](http://github.com/dracor-org/epdracor-sources) repository.

The following modifications to the original documents have been made:

- markup for words (`<tei:w>`) and punctuation (`<tei:pc>`) has been removed
- Wikidata IDs for plays have been added (see [index.xml](index.xml))
- Wikidata IDs for authors have been added (see [authors.xml](authors.xml))
- speakers have been identified for selected plays and a list of characters is
  being added (see JSON files in [meta/speakers](meta/speakers/))
- IDs and ID references reused in the DraCor documents have been sanitized

## Corpus selection

The tally of dramatic works in the Early Print corpus, as provided by its editors, amounted to 853 texts. 
In this initial phase, we set aside the 363 texts that lack speaker identification with `who` attributes in the original markup. 
From the remaining texts, we proceed to filter out 73 items which:

- are not dramatic texts, but rather poems (like Shakespeare's *[The Rape of Lucrece](https://texts.earlyprint.org/works/A12040))*, court entertainments, or masques (like Dekker's *[Arches of Triumph](https://texts.earlyprint.org/works/A02732)*)
- are collections of multiple plays (like Ben Johnson's *[Complete Works](https://texts.earlyprint.org/works/A04632_00)*) 
- are section of plays (like the first part of Dekker's [The Honest Whore](https://texts.earlyprint.org/works/A20062)), or incomplete 

The remaining 433 plays constitute the first version of EPDraCor.

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

### Adding new plays to the repo

1. add original documents to the `epdracor-sources` repo, see
  https://github.com/dracor-org/epdracor-sources#how-to-add-or-remove-plays
2. add entries in [index.xml](index.xml) providing a unique DraCor ID, a slug
  and if available a Wikidata ID
3. run the [XSLT transformation](#xslt-transformation), e.g.
  `./ep2dracor ../epdracor-sources/xml/*.xml`

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
