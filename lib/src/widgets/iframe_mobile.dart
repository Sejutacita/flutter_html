import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/navigation_delegate.dart';
import 'package:flutter_html/src/replaced_element.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
import 'package:webview_flutter/webview_flutter.dart' as webview;

/// [IframeContentElement is a [ReplacedElement] with web content.
class IframeContentElement extends ReplacedElement {
  final String? src;
  final double? width;
  final double? height;
  final NavigationDelegate? navigationDelegate;
  final UniqueKey key = UniqueKey();

  IframeContentElement({
    required String name,
    required this.src,
    required this.width,
    required this.height,
    required dom.Element node,
    required this.navigationDelegate,
  }) : super(name: name, style: Style(), node: node, elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    final sandboxMode = attributes["sandbox"];
    return IFrameContainer(
      width: width,
      height: height,
      name: name,
      navigationDelegate: navigationDelegate,
      renderContext: context,
      sandBoxMode: sandboxMode,
      src: src,
    );
  }
}

class IFrameContainer extends StatefulWidget {
  final String? src;
  final double? width;
  final double? height;
  final NavigationDelegate? navigationDelegate;
  final UniqueKey key = UniqueKey();
  final RenderContext renderContext;
  final String? sandBoxMode;
  IFrameContainer({
    required String name,
    required this.src,
    required this.width,
    required this.height,
    required this.navigationDelegate,
    required this.renderContext,
    required this.sandBoxMode,
  });
  @override
  State<IFrameContainer> createState() => _IFrameContainerState();
}

class _IFrameContainerState extends State<IFrameContainer> {
  late final webview.WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = webview.WebViewController()
      ..loadHtmlString(widget.src!)
      ..setJavaScriptMode(
        widget.sandBoxMode == null || widget.sandBoxMode == "allow-scripts"
            ? webview.JavaScriptMode.unrestricted
            : webview.JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
          webview.NavigationDelegate(onNavigationRequest: (request) async {
        //
        // final result =  NavigationDecision(
        //   url: request.url,
        //   isForMainFrame: request.isMainFrame,
        // );
        //
        // if (request.url.is) {
        //   return webview.NavigationDecision.prevent;
        // } else {
        return webview.NavigationDecision.navigate;
        // }
      }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? (widget.height ?? 150) * 2,
      height: widget.height ?? (widget.width ?? 300) / 2,
      child: ContainerSpan(
        style: widget.renderContext.style,
        newContext: widget.renderContext,
        child: webview.WebViewWidget(
          controller: _webViewController,
          // initialUrl: src,
          key: widget.key,
          gestureRecognizers: {
            Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer())
          },
        ),
      ),
    );
  }
}
