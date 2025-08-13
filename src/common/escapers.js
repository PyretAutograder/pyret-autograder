/**
 * NOTE: this file is adapted from @discordjs/formatters
 * https://github.com/discordjs/discord.js/blob/main/packages/formatters/src/escapers.ts
 */

/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "escape-code-block": ["arrow", ["String"], "String"],
      "escape-inline-code": ["arrow", ["String"], "String"],
      "escape-italic": ["arrow", ["String"], "String"],
      "escape-bold": ["arrow", ["String"], "String"],
      "escape-underline": ["arrow", ["String"], "String"],
      "escape-escape": ["arrow", ["String"], "String"],
      "escape-heading": ["arrow", ["String"], "String"],
      "escape-bulleted-list": ["arrow", ["String"], "String"],
      "escape-numbered-list": ["arrow", ["String"], "String"],
      "escape-masked-link": ["arrow", ["String"], "String"],
    },
  },
  nativeRequires: [],
  theModule: (runtime, _namespace, _uri) => {
    "use strict";
    /**
     * The options that affect what will be escaped.
     * @typedef {Object} EscapeMarkdownOptions
     * @property {boolean} [bold=true] - Whether to escape bold text.
     * @property {boolean} [bulletedList=true] - Whether to escape bulleted lists.
     * @property {boolean} [codeBlock=true] - Whether to escape code blocks.
     * @property {boolean} [codeBlockContent=true] - Whether to escape text inside code blocks.
     * @property {boolean} [escape=true] - Whether to escape `\`.
     * @property {boolean} [heading=true] - Whether to escape headings.
     * @property {boolean} [inlineCode=true] - Whether to escape inline code.
     * @property {boolean} [inlineCodeContent=true] - Whether to escape text inside inline code.
     * @property {boolean} [italic=true] - Whether to escape italics.
     * @property {boolean} [maskedLink=true] - Whether to escape masked links.
     * @property {boolean} [numberedList=true] - Whether to escape numbered lists.
     * @property {boolean} [strikethrough=true] - Whether to escape strikethroughs.
     * @property {boolean} [underline=true] - Whether to escape underlines.
     */

    /**
     * Escapes any markdown in a string.
     *
     * @param {string} text - Content to escape
     * @param {EscapeMarkdownOptions} [options={}] - Options for escaping the markdown
     * @returns {string}
     */
    function escapeMarkdown(text, options = {}) {
      const {
        codeBlock = true,
        inlineCode = true,
        bold = true,
        italic = true,
        underline = true,
        strikethrough = true,
        codeBlockContent = true,
        inlineCodeContent = true,
        escape = true,
        heading = true,
        bulletedList = true,
        numberedList = true,
        maskedLink = true,
      } = options;

      if (!codeBlockContent) {
        return text
          .split('```')
          .map((subString, index, array) => {
            if (index % 2 && index !== array.length - 1) return subString;
            return escapeMarkdown(subString, {
              inlineCode,
              bold,
              italic,
              underline,
              strikethrough,
              inlineCodeContent,
              escape,
              heading,
              bulletedList,
              numberedList,
              maskedLink,
            });
          })
          .join(codeBlock ? '\\`\\`\\`' : '```');
      }

      if (!inlineCodeContent) {
        return text
          .split(/(?<=^|[^`])`(?=[^`]|$)/g)
          .map((subString, index, array) => {
            if (index % 2 && index !== array.length - 1) return subString;
            return escapeMarkdown(subString, {
              codeBlock,
              bold,
              italic,
              underline,
              strikethrough,
              escape,
              heading,
              bulletedList,
              numberedList,
              maskedLink,
            });
          })
          .join(inlineCode ? '\\`' : '`');
      }

      let res = text;
      if (escape) res = escapeEscape(res);
      if (inlineCode) res = escapeInlineCode(res);
      if (codeBlock) res = escapeCodeBlock(res);
      if (italic) res = escapeItalic(res);
      if (bold) res = escapeBold(res);
      if (underline) res = escapeUnderline(res);
      if (strikethrough) res = escapeStrikethrough(res);
      if (heading) res = escapeHeading(res);
      if (bulletedList) res = escapeBulletedList(res);
      if (numberedList) res = escapeNumberedList(res);
      if (maskedLink) res = escapeMaskedLink(res);
      return res;
    }

    /** @typedef {(text: string) => string} Escaper */

    /** @type {Escaper} */
    function escapeCodeBlock(text) {
      return text.replaceAll('```', '\\`\\`\\`');
    }

    /** @type {Escaper} */
    function escapeInlineCode(text) {
      return text.replaceAll(/(?<=^|[^`])``?(?=[^`]|$)/g, (match) => (match.length === 2 ? '\\`\\`' : '\\`'));
    }

    /** @type {Escaper} */
    function escapeItalic(text) {
      let idx = 0;
      const newText = text.replaceAll(/(?<=^|[^*])\*([^*]|\*\*|$)/g, (_, match) => {
        if (match === '**') return ++idx % 2 ? `\\*${match}` : `${match}\\*`;
        return `\\*${match}`;
      });
      idx = 0;
      return newText.replaceAll(/(?<=^|[^_])(?<!<a?:.+|https?:\/\/\S+)_(?!:\d+>)([^_]|__|$)/g, (_, match) => {
        if (match === '__') return ++idx % 2 ? `\\_${match}` : `${match}\\_`;
        return `\\_${match}`;
      });
    }

    /** @type {Escaper} */
    function escapeBold(text) {
      let idx = 0;
      return text.replaceAll(/\*\*(\*)?/g, (_, match) => {
        if (match) return ++idx % 2 ? `${match}\\*\\*` : `\\*\\*${match}`;
        return '\\*\\*';
      });
    }

    /** @type {Escaper} */
    function escapeUnderline(text) {
      let idx = 0;
      return text.replaceAll(/(?<!<a?:.+|https?:\/\/\S+)__(_)?(?!:\d+>)/g, (_, match) => {
        if (match) return ++idx % 2 ? `${match}\\_\\_` : `\\_\\_${match}`;
        return '\\_\\_';
      });
    }

    /** @type {Escaper} */
    function escapeStrikethrough(text) {
      return text.replaceAll('~~', '\\~\\~');
    }

    /** @type {Escaper} */
    function escapeEscape(text) {
      return text.replaceAll('\\', '\\\\');
    }

    /** @type {Escaper} */
    function escapeHeading(text) {
      return text.replaceAll(/^( {0,2})([*-] )?( *)(#{1,3} )/gm, '$1$2$3\\$4');
    }

    /** @type {Escaper} */
    function escapeBulletedList(text) {
      return text.replaceAll(/^( *)([*-])( +)/gm, '$1\\$2$3');
    }

    /** @type {Escaper} */
    function escapeNumberedList(text) {
      return text.replaceAll(/^( *\d+)\./gm, '$1\\.');
    }

    /** @type {Escaper} */
    function escapeMaskedLink(text) {
      return text.replaceAll(/\[.+]\(.+\)/gm, '\\$&');
    }

    const wrapEscaper = (/** @type {Escaper} */ escaper, /** @type {string} */ name) => runtime.makeFunction(function(/** @type {string} */ text) {
      runtime.checkArity(1, arguments, name, false);
      runtime.checkString(text);
      return runtime.makeString(escaper(text));
    }, name)

    return runtime.makeModuleReturn({
      "escape-code-block": wrapEscaper(escapeCodeBlock, "escape-code-block"),
      "escape-inline-code": wrapEscaper(escapeInlineCode, "escape-inline-code"),
      "escape-italic": wrapEscaper(escapeItalic, "escape-italic"),
      "escape-bold": wrapEscaper(escapeBold, "escape-bold"),
      "escape-underline": wrapEscaper(escapeUnderline, "escape-underline"),
      "escape-strikethrough": wrapEscaper(escapeStrikethrough, "escape-strikethrough"),
      "escape-escape": wrapEscaper(escapeEscape, "escape-escape"),
      "escape-heading": wrapEscaper(escapeHeading, "escape-heading"),
      "escape-bulleted-list": wrapEscaper(escapeBulletedList, "escape-bulleted-list"),
      "escape-numbered-list": wrapEscaper(escapeNumberedList, "escape-numbered-list"),
      "escape-masked-link": wrapEscaper(escapeMaskedLink, "escape-masked-link"),
      "escape-markdown": runtime.makeFunction(escapeMarkdown, "escape-markdown")
    }, {});
  },
})
