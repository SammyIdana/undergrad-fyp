import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/water_data.dart';
import '../providers/chat_provider.dart';
import '../providers/water_data_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit(String text, WaterData? currentData) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    ref.read(chatProvider.notifier).sendUserMessage(text, currentData: currentData);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final waterData = ref.watch(waterDataProvider).asData?.value;
    final isDark = AppHelpers.isDarkMode(context);

    final bg = isDark ? AppColorsDark.background : AppColors.background;
    final cardBg = isDark ? AppColorsDark.card : AppColors.card;
    final textMain = isDark ? AppColorsDark.textMain : AppColors.textMain;
    final textSub = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    // Listen to changes to scroll down
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0) || next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water AI Assistant',
                  style: AppStyles.headingStyle.copyWith(fontSize: 16, color: textMain),
                ),
                Text(
                  'Diagnostics & Corrective Measures',
                  style: AppStyles.captionStyle.copyWith(fontSize: 11, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Chat',
            icon: Icon(Icons.refresh_rounded, color: textSub),
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Telemetry Quick Diagnostic Banner (if active sensor data available)
          if (waterData != null && waterData.status != 'WAITING')
            _buildLiveTelemetryBanner(waterData, isDark),

          // Message history list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length && chatState.isTyping) {
                  return _buildTypingIndicator(isDark);
                }
                final msg = chatState.messages[index];
                return _buildMessageItem(msg, isDark);
              },
            ),
          ),

          // Quick Prompt Action Chips
          _buildSuggestionChips(waterData, isDark),

          // Message input bar
          _buildInputBar(cardBg, textMain, textSub, waterData, isDark),
        ],
      ),
    );
  }

  Widget _buildLiveTelemetryBanner(WaterData data, bool isDark) {
    final statusColor = AppHelpers.getStatusColorForTheme(data.status, context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.surfaceOverlay : AppColors.surfaceOverlay,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Live: Turbidity ${data.turbidity.toStringAsFixed(1)} NTU • pH ${data.ph.toStringAsFixed(1)} • TDS ${data.tds.toStringAsFixed(0)} ppm',
              style: AppStyles.captionStyle.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ref.read(chatProvider.notifier).diagnoseTelemetry(data);
              _scrollToBottom();
            },
            child: Text(
              'Diagnose',
              style: AppStyles.paramLabelStyle.copyWith(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg, bool isDark) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (msg.forwardedContext != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    msg.forwardedContext!,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              Text(
                msg.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Assistant message
    final cardBg = isDark ? AppColorsDark.card : AppColors.card;
    final textMain = isDark ? AppColorsDark.textMain : AppColors.textMain;
    final textSub = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: msg.isDiagnosis
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark ? AppColorsDark.surfaceOverlay : AppColors.surfaceOverlay),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with bot icon and tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Water AI Specialist',
                style: AppStyles.labelStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (msg.isDiagnosis)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'DIAGNOSIS',
                    style: AppStyles.paramLabelStyle.copyWith(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Main text body
          Text(
            msg.text,
            style: AppStyles.subtitleStyle.copyWith(
              color: textMain,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),

          // Possible Causes Block
          if (msg.possibleCauses != null && msg.possibleCauses!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.cautionLight.withValues(alpha: 0.4) : AppColors.cautionLight.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.caution.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.caution, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Possible Root Causes',
                        style: AppStyles.labelStyle.copyWith(
                          color: AppColors.caution,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...msg.possibleCauses!.map(
                    (cause) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: AppColors.caution, fontWeight: FontWeight.bold, fontSize: 13)),
                          Expanded(
                            child: Text(
                              cause,
                              style: AppStyles.captionStyle.copyWith(
                                color: textMain,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Corrective Measures Block
          if (msg.correctiveMeasures != null && msg.correctiveMeasures!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.safeLight.withValues(alpha: 0.4) : AppColors.safeLight.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.safe.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.build_circle_rounded, color: AppColors.safe, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Suggested Corrective Measures',
                        style: AppStyles.labelStyle.copyWith(
                          color: AppColors.safe,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...msg.correctiveMeasures!.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            margin: const EdgeInsets.only(right: 6, top: 2),
                            decoration: const BoxDecoration(
                              color: AppColors.safe,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: AppStyles.captionStyle.copyWith(
                                color: textMain,
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            msg.timestamp.toLocal().toString().split('.')[0].substring(11, 16),
            style: AppStyles.captionStyle.copyWith(color: textSub, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.card : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'AI is evaluating water parameters...',
              style: AppStyles.captionStyle.copyWith(
                fontSize: 12,
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(WaterData? waterData, bool isDark) {
    final chips = [
      'Diagnose live sensors',
      'Why is turbidity high?',
      'Is current water safe to drink?',
      'How to lower TDS?',
      'Calibrate sensors',
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final title = chips[index];
          return ActionChip(
            label: Text(title),
            labelStyle: AppStyles.paramLabelStyle.copyWith(
              fontSize: 11,
              color: isDark ? AppColorsDark.textMain : AppColors.textMain,
            ),
            backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            onPressed: () {
              _handleSubmit(title, waterData);
            },
          );
        },
      ),
    );
  }

  Widget _buildInputBar(
    Color cardBg,
    Color textMain,
    Color textSub,
    WaterData? waterData,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.surfaceOverlay : AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: TextStyle(color: textMain, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask water questions or describe issue...',
                    hintStyle: TextStyle(color: textSub, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (text) => _handleSubmit(text, waterData),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: () => _handleSubmit(_textController.text, waterData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
