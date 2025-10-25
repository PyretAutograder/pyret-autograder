declare const __pyret_module_return: unique symbol;
type ret = { [__pyret_module_return]: void };

declare const __pyret_value: symbol;
type val = { [__pyret_value]: void };

declare const __pyret_type: unique symbol;
type typ = { [__pyret_type]: void };

interface PyretFFI {
  throwMessageException(msg: string): never;

  equal: val;
  notEqual: val;
  unknown: val;
  isEqual(v: val): boolean;
  isNotEqual(v: val): boolean;
  isUnknown(v: val): boolean;
  isEqualityResult(v: val): boolean;

  cases(
    pred: (val: val) => boolean,
    predName: string,
    val: val,
    casesObj: Record<string, func>
  ): val;
  checkArity: PyretRuntime["checkArity"];

  makeList(items: val[]): val;
  isList(val: val): boolean;
  isLink(val: val): boolean;
  isEmpty(val: val): boolean;
  listLength(val: val): number;

  toArray(val: val): val[];

  isOption: (val: val) => boolean;
  isSome: (val: val) => boolean;
  isNone: (val: val) => boolean;
  makeSome(val: val): val;
  makeNone: () => val;

  isEither: (val: val) => boolean;
  isLeft: (val: val) => boolean;
  isRight: (val: val) => boolean;
  makeLeft(val: val): val;
  makeRight(val: val): val;
}

declare const __type_brander__: unique symbol;

type SrcLocJs =
  | [builtInModule: string]
  | [
      source: string,
      startLine: number,
      startColumn: number,
      startChar: number,
      endLine: number,
      endColumn: number,
      endChar: number
    ];
type func = (...args: any[]) => any;

// NOTE: this is far from complete
interface PyretRuntime {
  builtins: val;
  run(
    program: unknown,
    namespace: unknown,
    options: unknown,
    onDone: unknown
  ): unknown;
  runThunk(f: unknown, then: unknown, options?: unknown): unknown;
  safeCall<T, U>(fun: () => T, after: (result: T) => U, stackFrame: string): U;

  ffi: PyretFFI;

  pauseStack(
    callback: (restarter: { resume: (val: val) => void }) => void
  ): val;
  await<T>(promise: Promise<T>): T;

  getField<T>(obj: val, field: string): T;
  getFieldLoc<T>(obj: val, field: string, loc: SrcLocJs): T;
  getFieldRef<T>(obj: val, field: string, loc: SrcLocJs): T;
  getFields(obj: val): string[];
  getBracket<T>(loc: SrcLocJs, obj: val, field: string): T;
  getColonField<T>(val: val, field: string): T;
  getColonFieldLoc<T>(val: val, field: string, loc: SrcLocJs): T;
  getTuple<T>(tup: val, index: number, loc: SrcLocJs): T;
  checkTupleBind(tup: val, index: number, loc: SrcLocJs): boolean;
  extendObj(loc: SrcLocJs, obj: val, extension: Record<string, val>): val;

  isBase(v: unknown): v is val;
  isNothing(v: unknown): v is val;
  isNumber(v: unknown): v is val;
  isRoughnum(v: unknown): v is number;
  isExactnum(v: unknown): v is val;
  isString(v: unknown): v is string;
  isBoolean(v: unknown): v is boolean;
  isFunction(v: unknown): v is func;
  isMethod(v: unknown): v is func;
  isTuple(v: unknown): v is val;
  isObject(v: unknown): v is val;
  isDataValue(v: unknown): v is val;
  isRef(v: unknown): v is val;
  isOpaque(v: unknown): v is val;
  isPyretVal(v: unknown): v is val;

  isSuccessResult(v: unknown): boolean;
  makeSuccessResult(r: unknown): val;
  isFailureResult(v: val): boolean;
  makeFailureResult(e: unknown): val;

  makeNothing(): val;
  makeNumber(n: number): val;
  makeNumberBig(n: unknown): val;
  makeNumberFromString(s: string): val;
  makeBoolean(b: boolean): val;
  makeString(s: string): val;
  makeFunction(fun: func, name: string): val;
  makeMethod(meth: func, full_meth: func, name: string): val;
  // ...
  makeTuple(tup: val[]): val;
  makeObject(obj: Record<string, val>): val;
  makeArray(arr: val[]): val;
  makeArrayN(n: number): val;
  // ...

  wrap(v: any): val;
  unwrap<T>(v: val): T;

  checkArity: (
    expected: number,
    args: IArguments,
    source: string,
    isMethod: boolean
  ) => void;
  checkString(v: string): void;
  checkNumber(v: number): void;
  checkExactnum(v: number): void;
  checkRoughnum(v: number): void;
  checkNumInteger(v: number): void;
  checkNumRational(v: number): void;
  checkNumNegative(v: number): void;
  checkNumPositive(v: number): void;
  checkNumNonPositive(v: number): void;
  checkNumNonNegative(v: number): void;
  checkTuple(v: val): void;
  checkArray(v: val): void;
  checkBoolean(v: boolean): void;
  checkObject(v: val): void;
  checkFunction(v: val): void;
  checkMethod(v: val): void;
  checkOpaque(v: val): void;
  checkPyretVal(v: unknown): void;

  nothing: val;
  toRepr(v: val): val;

  makeSrcloc(srcloc: SrcLocJs): val;

  makeJSModuleReturn: (jsMod: any) => ret;
  makeModuleReturn: (
    values: Record<string, val>,
    types: Record<string, typ>,
    internal?: Record<string, unknown>
  ) => ret;

  modules: Record<string, val>;

  stdout: typeof process.stdout;
  stderr: typeof process.stderr;
  stdin: typeof process.stdin;
  console: typeof console;

  makePrimAnn: unknown;
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

type RequireSpec =
  | { "import-type": "builtin"; name: string }
  | { "import-type": "dependency"; protocol: string; args: any[] };
interface PyretModule {
  requires: RequireSpec[];
  nativeRequires: any[];
  provides: {
    values?: Record<string, InteropSignature>;
    types?: Record<string, typ>;
  };
  theModule: (
    runtime: PyretRuntime,
    namespace: string,
    uri: string,
    ...imports: any[]
  ) => ret;
}
