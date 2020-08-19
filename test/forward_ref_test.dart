@TestOn('browser')
library react.forward_ref_test;

import 'dart:html';
import 'dart:js_util';

import 'package:react/react.dart' as react;
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_test_utils.dart' as rtu;
import 'package:test/test.dart';

import 'factory/common_factory_tests.dart';

main() {
  group('forwardRef2', () {
    group('- common factory behavior -', () {
      commonFactoryTests(
        ForwardRef2Test,
        // ignore: invalid_use_of_protected_member
        dartComponentVersion: ReactDartComponentVersion.component2,
      );
    });

    group('ref forwarding functional testing (to a div) -', () {
      refTests<DivElement>(ForwardRef2Test, verifyRefValue: (ref) {
        expect(ref, TypeMatcher<DivElement>());
      });
    });

    group('passes the ref to the function as expected without wrapping it', () {
      dynamic getActualRef(dynamic inputRef) {
        dynamic actualRef;
        rtu.renderIntoDocument(ForwardRef2Test({
          'ref': inputRef,
          'onDartRenderWithRef': (props, ref) {
            actualRef = ref;
          }
        }));
        return actualRef;
      }

      group('when the ref is', () {
        test('null', () {
          expect(getActualRef(null), isNull);
        });

        test('a callback ref', () {
          callbackRef(ref) {}
          expect(getActualRef(callbackRef), same(callbackRef));
        });

        test('a ref object', () {
          final refObject = createRef();
          // We create a new Ref object, so it won't be the same, but we can expect that it's backed by the same js ref.
          expect(getActualRef(refObject), isA<Ref>().having((ref) => ref.jsRef, 'jsRef', same(refObject.jsRef)));
        });
      });

      test('unless it\'s a JS ref object', () {
        final jsRefObject = React.createRef();
        expect(getActualRef(jsRefObject), isA<Ref>().having((ref) => ref.jsRef, 'jsRef', same(jsRefObject)),
            reason: 'should have wrapped the JS ref in the Dart interop class');
      });
    });

    group('sets displayName on the rendered component as expected', () {
      test('unless the displayName argument is not passed to forwardRef2', () {
        var ForwardRefTestComponent = forwardRef2((props, ref) {});
        expect(getProperty(getProperty(ForwardRefTestComponent.type, 'render'), 'name'), anyOf('', isNull));
      });

      test('when displayName argument is passed to forwardRef2', () {
        const name = 'ForwardRefTestComponent';
        var ForwardRefTestComponent = forwardRef2((props, ref) {}, displayName: name);
        expect(getProperty(getProperty(ForwardRefTestComponent.type, 'render'), 'name'), name);
      });
    });
  });
}


// ignore: deprecated_member_use_from_same_package
final ForwardRefTest = react.forwardRef((props, ref) {
  props['onDartRender']?.call(props);
  return react.div({...props, 'ref': ref});
});

final ForwardRef2Test = react.forwardRef2((props, ref) {
  props['onDartRender']?.call(props);
  props['onDartRenderWithRef']?.call(props, ref);
  return react.div({...props, 'ref': ref});
});