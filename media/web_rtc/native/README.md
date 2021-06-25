# Native 代码

[webrtc 目前最新版本是 M89，其更新记录就保存在源代码的 docs/release-notes.md](https://chromium.googlesource.com/external/webrtc/+/refs/heads/master/docs/release-notes.md)

## 目录结构

```
.
├── BUILD.gn
├── CODE_OF_CONDUCT.md
├── DEPS
├── DIR_METADATA
├── ENG_REVIEW_OWNERS
├── LICENSE
├── OWNERS
├── PATENTS
├── PRESUBMIT.py
├── README.chromium
├── README.md
├── WATCHLISTS
├── abseil-in-webrtc.md
├── api // 定义了对外保留的接口部分，是可以别外部程序调用的部分。
│   ├── BUILD.gn
│   ├── DEPS
│   ├── OWNERS
│   ├── README.md
│   ├── adaptation
│   ├── array_view.h
│   ├── array_view_unittest.cc
│   ├── async_dns_resolver.h
│   ├── async_resolver_factory.h
│   ├── audio
│   ├── audio_codecs
│   ├── audio_options.cc
│   ├── audio_options.h
│   ├── call
│   ├── candidate.cc
│   ├── candidate.h
│   ├── create_peerconnection_factory.cc 
│   ├── create_peerconnection_factory.h // 创建 PeerConnectionFactory 的接口
│   ├── peer_connection_factory_proxy.h 
│   ├── peer_connection_interface.cc
│   ├── peer_connection_interface.h // 定义 create_peerconnection_factory 和 create_peerconnection。 实现是在 pc/peer_connection_factory 中。
│   ├── crypto
│   ├── crypto_params.h
│   ├── data_channel_interface.cc
│   ├── data_channel_interface.h
│   ├── dtls_transport_interface.cc
│   ├── dtls_transport_interface.h
│   ├── dtmf_sender_interface.h
│   ├── fec_controller.h
│   ├── fec_controller_override.h
│   ├── frame_transformer_interface.h
│   ├── function_view.h
│   ├── function_view_unittest.cc
│   ├── g3doc
│   ├── ice_transport_factory.cc
│   ├── ice_transport_factory.h
│   ├── ice_transport_interface.h
│   ├── jsep.cc
│   ├── jsep.h
│   ├── jsep_ice_candidate.cc
│   ├── jsep_ice_candidate.h
│   ├── jsep_session_description.h
│   ├── media_stream_interface.cc
│   ├── media_stream_interface.h
│   ├── media_stream_proxy.h
│   ├── media_stream_track.h
│   ├── media_stream_track_proxy.h
│   ├── media_types.cc
│   ├── media_types.h
│   ├── neteq
│   ├── network_state_predictor.h
│   ├── notifier.h
│   ├── numerics
│   ├── packet_socket_factory.h
│   ├── peer_connection_proxy.h
│   ├── priority.h
│   ├── proxy.cc
│   ├── proxy.h
│   ├── ref_counted_base.h
│   ├── rtc_error.cc
│   ├── rtc_error.h
│   ├── rtc_error_unittest.cc
│   ├── rtc_event_log
│   ├── rtc_event_log_output.h
│   ├── rtc_event_log_output_file.cc
│   ├── rtc_event_log_output_file.h
│   ├── rtc_event_log_output_file_unittest.cc
│   ├── rtp_headers.cc
│   ├── rtp_headers.h
│   ├── rtp_packet_info.cc
│   ├── rtp_packet_info.h
│   ├── rtp_packet_info_unittest.cc
│   ├── rtp_packet_infos.h
│   ├── rtp_packet_infos_unittest.cc
│   ├── rtp_parameters.cc
│   ├── rtp_parameters.h
│   ├── rtp_parameters_unittest.cc
│   ├── rtp_receiver_interface.cc
│   ├── rtp_receiver_interface.h
│   ├── rtp_sender_interface.cc
│   ├── rtp_sender_interface.h
│   ├── rtp_transceiver_direction.h
│   ├── rtp_transceiver_interface.cc
│   ├── rtp_transceiver_interface.h
│   ├── scoped_refptr.h
│   ├── scoped_refptr_unittest.cc
│   ├── sctp_transport_interface.cc
│   ├── sctp_transport_interface.h
│   ├── sequence_checker.h
│   ├── sequence_checker_unittest.cc
│   ├── set_local_description_observer_interface.h
│   ├── set_remote_description_observer_interface.h
│   ├── stats
│   ├── stats_types.cc
│   ├── stats_types.h
│   ├── task_queue
│   ├── test
│   ├── transport
│   ├── turn_customizer.h
│   ├── uma_metrics.h
│   ├── units
│   ├── video
│   ├── video_codecs
│   ├── video_track_source_proxy.h
│   └── voip
├── audio
├── base
├── build
├── build_overrides
├── buildtools
├── call
├── codereview.settings
├── common_audio
├── common_video
├── data
├── docs
├── examples
├── g3doc
├── g3doc.lua
├── license_template.txt
├── logging
├── media
├── modules
├── native-api.md
├── net
├── out
├── p2p
├── pc
├── presubmit_test.py
├── presubmit_test_mocks.py
├── pylintrc
├── resources
├── rtc_base
├── rtc_tools
├── sdk
├── stats
├── style-guide
├── style-guide.md
├── system_wrappers
├── test
├── testing
├── third_party
├── tools
├── tools_webrtc
├── video
├── webrtc.gni
├── webrtc_lib_link_test.cc
└── whitespace.txt
```