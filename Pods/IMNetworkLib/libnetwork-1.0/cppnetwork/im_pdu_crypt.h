/*****************************************************************************
 Name        : pdu.h
 Author      : tianshan
 Date        : 2015年7月8日
 Description : 从客户端移植过来的协议解包封包器，
 后续要跟现有的统一起来，现在先这样用着（2015-07-15，tianshan）
 ******************************************************************************/

#ifndef LIBNETWORK_1_0_CPPNETWORK_PDU_H_
#define LIBNETWORK_1_0_CPPNETWORK_PDU_H_

#include "databuffer.h"
#include <string>
namespace cppnetwork
{
//加密标识
enum
{
	NON_CRYPT = 0, // 不加密
	RSA_CRYPT = 1, // RSA加密
	TEA_CRYPT = 2, // TEA加密
};
// module id
enum
{
	MID_SERVER = 1,     // 服务器之间的数据包
	MID_LOGIN = 2,     // 登陆模块
	MID_BUDDY = 3,     // 好友管理模块
	MID_MSG = 4,     // 单聊消息模块
	MID_GROUP = 5,     // 群消息模块
	MID_CINFO = 6,     // cinfo计数推送模块，原来的cinfo
	MID_GENERAL = 7,     // 通用模块
	MID_STATUS = 8,     // 没实际的数据包用这个module_id，只有AccessServer会用到这个值
	MID_MONITOR = 9,     // 客户端统计数据上报
	MID_IPSERVICE = 10,  // ipservice模块,客户端不会发送这类业务请求
	MID_CRYPT = 11,  // 加密模块，加密协议的四次握手
};

enum
{
	CID_CRYPT_REG_REQ = 1,  // client发送加密请求
	CID_CRYPT_REG_RESP = 2,  // Server返回RSA公共密钥
	CID_CRYPT_TEA_REQ = 3,  // client发送TEA加密密钥
	CID_CRYPT_TEA_RESP = 4,  // Server确认TEA密钥，双方确认开始进行加密传输
	CID_CRYPT_TEST_MSG = 5,  // 加密测试协议，后面跟一段测试数据
};

#define IM_PDU_VERSION			0x80
#define IM_PDU_HEADER_LEN       36

#define ROLE_XIAOXIAN_BIT		0x80000000	// 小仙
#define ROLE_XIAOXIA_BIT		0x40000000	// 小侠
#define ROLE_MASK				0xFFFFFF	// 用户类型的高字节预留给小仙/小侠和其他用户

#define FROM_SITE_XIAODIAN      0x00000007
#define FROM_SITE_MOGUJIE       0x00000008

#define PDU_TYPE(module_id, command_id) ((module_id << 16U) | command_id

#pragma pack(1)
class PduHeader_t
{
public:
	uint32_t length;             // 数据包长度，包括包头
	uint16_t version;            // 版本号
	uint16_t flag;               // 标记: 分拆数据包，压缩
	uint16_t module_id;          // 模块号
	uint16_t command_id;         // 命令号
	uint16_t srv_number;         // 接入服务器号, 服务端用，客户端置0
	uint16_t inner_srv_number;   // 内部服务器号, 服务端用，客户端置0
	uint32_t cli_handle;         // 客户端handle, 服务端用, 客户端置0
	uint32_t user_id;            // 请求者的userId, 服务端用，客户端置0
	uint32_t srv_timetick;       // 服务端时间戳, 服务端用, 客户端置0
	uint32_t seq_no;             // 序列号
	uint32_t reserved;           // 保留
};
#pragma pack()

class PduCryptHeader_t: public PduHeader_t
{
public:
	PduCryptHeader_t()
	{
		length = 0;
		version = IM_PDU_VERSION;
		flag = 0;
		module_id = 0;
		command_id = 0;
		srv_number = 0;
		inner_srv_number = 0;
		cli_handle = 0;
		user_id = 0;
		srv_timetick = 0;
		seq_no = 0;
		reserved = 0;
	}

	//通过内存中的数据初始化一个pdu_header， 用于协议解析;
	bool setup(const void *data, int len)
	{
		if (len < (int) sizeof(PduHeader_t))
			return false;

		DataBuffer data_buffer;
		data_buffer.writeBytes(data, sizeof(PduHeader_t));
		UnBody(data_buffer);

		return true;
	}

	//序列化
	void Body(DataBuffer &out)
	{
		out.writeInt32(length);
		out.writeInt16(version);
		out.writeInt16(flag);
		out.writeInt16(module_id);
		out.writeInt16(command_id);
		out.writeInt16(srv_number);
		out.writeInt16(inner_srv_number);
		out.writeInt32(cli_handle);
		out.writeInt32(user_id);
		out.writeInt32(srv_timetick);
		out.writeInt32(seq_no);
		out.writeInt32(reserved);
	}

	//反序列化
	bool UnBody(DataBuffer &in)
	{
		if (in.getDataLen() < IM_PDU_HEADER_LEN)
			return false;

		in.readInt32(length);
		in.readInt16(version);
		in.readInt16(flag);
		in.readInt16(module_id);
		in.readInt16(command_id);
		in.readInt16(srv_number);
		in.readInt16(inner_srv_number);
		in.readInt32(cli_handle);
		in.readInt32(user_id);
		in.readInt32(srv_timetick);
		in.readInt32(seq_no);
		in.readInt32(reserved);

		return true;
	}
};

class IPack
{
public:
	virtual void Body(DataBuffer &out) = 0;

	virtual bool UnBody(DataBuffer &in) = 0;

	PduCryptHeader_t _header;
};

class CryptRegReq: public IPack
{
public:
	CryptRegReq()
	{
		_header.module_id = MID_CRYPT;
		_header.command_id = CID_CRYPT_REG_REQ;
	}

	void Body(DataBuffer &out)
	{
		_header.length = sizeof(_header);
		_header.Body(out);
	}

	bool UnBody(DataBuffer &in)
	{
		return _header.UnBody(in);
	}
};

class CryptRegRsp: public IPack
{
public:

	CryptRegRsp()
	{
		_header.module_id = MID_CRYPT;
		_header.command_id = CID_CRYPT_REG_RESP;
	}

	void set_rsa_public_key(const string key)
	{
		_rsa_public_key = key;
	}

	const string & get_rsa_public_key()
	{
		return _rsa_public_key;
	}

	void Body(DataBuffer &out)
	{
		_header.length = sizeof(PduHeader_t) + _rsa_public_key.length();

		_header.Body(out);
		out.writeBytes(_rsa_public_key.c_str(), _rsa_public_key.length());
	}

	bool UnBody(DataBuffer &in)
	{
		if (_header.UnBody(in)) {
			printf("before unbody rsa, datalen:%d \n", in.getDataLen());
			_rsa_public_key.assign(in.getData(), in.getDataLen());
			return true;
		}

		return false;
	}

	std::string _rsa_public_key;
};

class CryptKeyReq: public IPack
{
public:
	CryptKeyReq()
	{
		_header.module_id = MID_CRYPT;
		_header.command_id = CID_CRYPT_TEA_REQ;
	}

	void set_tea_key(const uint32_t *key)
	{
		_tea_key[0] = key[0];
		_tea_key[1] = key[1];
		_tea_key[2] = key[2];
		_tea_key[3] = key[3];
	}

	void get_tea_key(uint32_t *key)
	{
		key[0] = _tea_key[0];
		key[1] = _tea_key[1];
		key[2] = _tea_key[2];
		key[3] = _tea_key[3];
	}

	void Body(DataBuffer &out)
	{
		_header.length = sizeof(_header) + sizeof(_tea_key);
		_header.Body(out);
		out.writeInt32(_tea_key[0]);
		out.writeInt32(_tea_key[1]);
		out.writeInt32(_tea_key[2]);
		out.writeInt32(_tea_key[3]);
	}

	bool UnBody(DataBuffer &in)
	{
		if (_header.UnBody(in)) {
			in.readInt32(_tea_key[0]);
			in.readInt32(_tea_key[1]);
			in.readInt32(_tea_key[2]);
			in.readInt32(_tea_key[3]);
			return true;
		}
		return false;
	}

	uint32_t _tea_key[4];
};

class CryptKeyRsp: public IPack
{
public:
	CryptKeyRsp()
	{
		_header.module_id = MID_CRYPT;
		_header.command_id = CID_CRYPT_TEA_RESP;
	}

	void Body(DataBuffer &out)
	{
		_header.length = sizeof(_header);
		_header.Body(out);
	}

	bool UnBody(DataBuffer &in)
	{
		return _header.UnBody(in);
	}
};

class CryptTestMsg: public IPack
{
public:

	CryptTestMsg()
	{
		_header.module_id = MID_CRYPT;
		_header.command_id = CID_CRYPT_TEST_MSG;
	}

	void set_msg(const string msg)
	{
		_msg = msg;
	}

	const string & get_msg()
	{
		return _msg;
	}

	void Body(DataBuffer &out)
	{
		_header.length = sizeof(PduHeader_t) + _msg.length();
		_header.Body(out);
		out.writeBytes(_msg.c_str(), _msg.length());
	}

	bool UnBody(DataBuffer &in)
	{
		if (_header.UnBody(in)) {
			_msg.assign(in.getData(), in.getDataLen());
			return true;
		}

		return false;
	}

	std::string _msg;
};

} /* namespace cppnetwork */

#endif /* LIBNETWORK_1_0_CPPNETWORK_PDU_H_ */
