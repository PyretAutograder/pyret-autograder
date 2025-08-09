declare const __pyret_module_return: unique symbol;
type ret = typeof __pyret_module_return;

declare const __pyret_value: unique symbol;
type val = typeof __pyret_value;

declare const __pyret_type: unique symbol;
type typ = typeof __pyret_type;

interface PyretFFI {
  makeSome: (val: val) => val;
  makeNone: () => val;
}

// NOTE: this is far from complete
interface PyretRuntime {
  stdout: typeof process.stdout;
  stderr: typeof process.stderr;
  stdin: typeof process.stdin;
  console: typeof console;

  ffi: PyretFFI;

  makeString: (s: string) => val;
  makeNumber: (n: number) => val;
  makeNumberBig: (n: bigint) => val;
  makeNumberFromString: (s: string) => val;
  makeBoolean: (b: boolean) => val;
  makeList: (l: val[]) => val;
  makeFunction: (fun: (...args: any[]) => any, name: string) => val;

  checkArity: (
    expected: number,
    args: IArguments,
    source: string,
    isMethod: boolean
  ) => void;
  checkString: (v: string) => void;
  checkNumber: (v: number) => void;
  checkExactnum: (v: number) => void;
  checkRoughnum: (v: number) => void;
  checkNumInteger: (v: number) => void;
  checkNumRational: (v: number) => void;
  checkNumNegative: (v: number) => void;
  checkNumPositive: (v: number) => void;
  checkNumNonPositive: (v: number) => void;
  checkNumNonNegative: (v: number) => void;
  checkTuple: (v: val) => void;
  checkArray: (v: val) => void;
  checkBoolean: (v: boolean) => void;
  checkObject: (v: val) => void;
  checkFunction: (v: val) => void;
  checkMethod: (v: val) => void;
  checkOpaque: (v: val) => void;
  checkPyretVal: (v: unknown) => void;

  isString: (v: unknown) => v is string;
  isNumber: (v: unknown) => v is number;
  isBoolean: (v: unknown) => v is boolean;
  isFunction: (v: unknown) => v is (...args: any[]) => any;
  isList: (v: unknown) => v is val[];
  getListLength: (l: val) => number;
  getListElements: (l: val) => val[];
  getFunctionArity: (f: val) => number;

  nothing: val;

  toRepr: (v: val) => val;

  makeModuleReturn: (
    values: Record<string, unknown>,
    types: Record<string, unknown>,
    internal?: Record<string, unknown>
  ) => ret;
}

type PrimType =
  | "Number"
  | "String"
  | "Boolean"
  | "Nothing"
  | "Any"
  | "tany"
  | "tbot";
type TypeId = ["tid", string];
type Arrow = ["arrow", InteropSignature[], InteropSignature];
type ForAll = ["forall", string[], InteropSignature];
type ListOf = ["List", InteropSignature];
type ArrayOf = ["Array", InteropSignature];
type RawArrayOf = ["RawArray", InteropSignature];
type OptionOf = ["Option", InteropSignature];
type Maker = ["Maker", InteropSignature];
type InteropSignature =
  | ForAll
  | Arrow
  | TypeId
  | PrimType
  | ListOf
  | ArrayOf
  | RawArrayOf
  | OptionOf
  | Maker;

interface PyretModule {
  requires: string[];
  nativeRequires: any[];
  provides: {
    values: Record<string, InteropSignature>;
    // types: Record<string, typ>;
  };
  theModule: (
    runtime: PyretRuntime,
    namespace: string,
    uri: string,
    ...imports: any[]
  ) => ret;
}
