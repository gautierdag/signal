��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qX?   /home/lgpu0444/diagnostics-shapes/baseline/models/shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XJ   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   43980784q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   44670064qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   42892080qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   42892176qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   43110352q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   43348528q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   43387008q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XP   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   43255152q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   43589488q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   43255248q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   42995776q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   43953520q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   42840816r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   43354144r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   43020912r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   43354240r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   32765664rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   42868224rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   43687072rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   44634416rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   44171536rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XL   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   44637424r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   44637520r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   32765664qX   42840816qX   42868224qX   42892080qX   42892176qX   42995776qX   43020912qX   43110352qX   43255152q	X   43255248q
X   43348528qX   43354144qX   43354240qX   43387008qX   43589488qX   43687072qX   43953520qX   43980784qX   44171536qX   44634416qX   44637424qX   44637520qX   44670064qe.       ���?`6�?K �?wؙ?#p�?+�?��?u�?!�?�C�?\Q�?�e�?�(�?'�?&�?�P�?�Վ?ڢ?c]�?-�?       jz�?�\�?�=@6�?�6@�K7@�5�?q4@��&@v��?,V�?M�@�N@l&@�5@@�@��?�@V@�@S�
@       �I�=��=���=��g=�8�=w>�==E��(�>S��=��*>];�=R��=!4�=��K>���=�c>�b�=�>       ��?{�q?�?&�?�5�?`C`?Qt�?	O^?;um?9Pr?)p?81h?�px?�`?�?�Ɓ?e\�?ܞ~?w�J?1>p?       l���^�<��0�o�%��HI��ϔ= -Q>+��=Lj�=��=*eX=���y�'�jԯ=�gI����=u��_/�=�h*>���       ��ͻ&y�<�S=��<�&B<eZ�<��=��C<�f��t�=.@�;�Z>�0>&��=��������>B��=r)�<      ����ҼGt�<ut��R=_�2���!��=(>��>VO�p��=M�g=-T�=�����r< ����O>��E=~W���\>�Ƀ>��*9��ڽ畎�K`~�K���i�Jyv���)=�>4O=��M=p��=�	�s嚽����n&���z>c�>x7��@�o	�T�=<�0<�?6>�� =�B>��=!��nY�=�}�<>J;��<�/=w�c�7��OJ��jM����W�2>W�¼e���H>����X띾�>�Z!=��A�E���.���$&>lp�c^ڽĵJ�ڢF>�=|e�<^�����2>��7>��!���p���'���>�Ȣ���v�o���m����=�!=	E���/>���=˼>a�6=�h=�/����;�#Ͻ�3�=݊�>JA���X�d8D���4>��=��^>r���X�{=�<�=f,>��<��.�i
�<N� =ǐ�=�=G=�����L]��S"=�-��g	�	p�==��> 6�=�W�=�Q�� NE>�E���3�=�����	>�Q���	�F\��67V<��0=�0{�6��X���*��e�K�|�����B��G�>����;9J>~���a
*��Y���+�
��UB�=]��8/!>Ny��g<�>��H�nIڻ�'�=h�c<g׿=����h>'�C>M�q�[D��&H>9��J><l鈾�$ֽ.��=���7��/�Q>�)�=E��=ֵ+��V��M�=Y5=�$��<z���v%��3
>ŽW]N=�5Q���V��k{=J�"�x�(>�ڏ�yN���Z<=觬>R�=aR%��0>,���p�=��E> ��<.��-�&�L=Z=o >�?��<����*��S'�1��<e'���ٽ��%���>���=8�/���d��c����p>���X��tB<p�F>"��BSY�&�̾�y2���>C�=a7>���==>/��~}���4>PY�>$�s���&�\�����B�6���]�=��=����/�㧡�2�̼��<=�>�qP>LG�=p�x����:"�n��/��8�n>2�8���4���x�ݱ�<H��[\D>���ƥ��M=d�[�����R��i�<Tڣ>iih�Gȓ�)+�=j�3=�೾�����C�;�W��i��8Ӿ�� ��0<�����M=9�$�S5S�]�;�!���'z�:+���qR��\\=4����=d�½I
����=b]�Z�g>� $����<�(>}xY�g�	�V��=X�@>L�>I,���[>���=v����踼�n�<�_�W!�;]�>��<�m>4V�=*7�ĩ$>���;a�������=�L>����ʽw��=D82>Hf[��݇='Ѷ�zwq�2�=^#����M��<XM޽ht,�_i���X&�$(H=�/Խ����z=\+=�7�<I���b�<?����}�=�����n[�����d=��Y=�A[=�Z���P=
��<��0����L�=�j���a>��?>��2�_�t�>k�y���>;Ix���P�z��U�n=� >[1��W߽!�>�>�nn=�";N�>	�#���-J���J<VP���<p�w����뿄=��3���h��y->����=�[�=�^˽FC>�,]=���=���t��<��޽�^L�4��A��&y�㓴���=>��?<-��;�膾���=�f�? 2��j>�)u�gB��>�^$��^8>4G�=�۪=c�ݽ�!��wݹ!�7>f��밽�[�!H��ľӃ����;/5�*�=�}����9=a�?j�=�@}�&ܼ;j��=����s��%�>U��=��f>Iǭ�oe�<���|��<M��=׉ý�D>���=�ẽ/�p=��M�[�V<�bս'h�=��[>u(>|��=tT=K�|=1Z���LǾ})�=�ݢ<f̽��>�|q=�<��%��(��Ħ��2j���ེb���8���߆=���,k(�ٔC<�r�;d���;3���b�n觽��B罢\���8��;�=/�>)�;
e�<M����,;`��먻�=Qf��{@�0@�f5�������=�#p��Q�<g��<�]D�"�<Z�>��=W�=�8�=�r����/��O)>��P-�:�U�=le�<�a�<�)�=�b�=g�>�e�7��h��N)?����=�� �(=��S=�ؠ�Qy��=����\񽘧Z���&=%�=�&7���<�O���ɽ��y>�Y���a�=7��5VH��>�L>~P��J=ª�=�J�S<��]��.�a�>�z<��1�ϯɽN���Y'5��]=�_�=s�<U�%���ؼ�K<�,>�>3=�=�[�=�Ƀ=����Ƽ�~Q�G~�=�>�<C�����v>觃>O����}5�y������<<G>�k=Z�;M���U:��r'>yו<�1>S�L��Ǐ=��H;OC�1����Z��~��>�╽Y`����ҽ��=�{�-�ݼ��>��ݽ��W=�i�=�7F��eU�a-<=Sa�������=�ɯ=��=�Fo=ĉ<������9>��$�'�[�w����">v�P>��u>����iJ�=�H=��	��p�=>n>4'㽜��=է缷Ó�L/����<F�p�eY�<�	=�)l<�'B��h�=]�5>�0�=(���F"�;|{�>#�=�D=SQ1>f�=��
=m�O�O�]<;�>��>����>��=�$޽ꧨ=������\>q�9<-j(����=�c�<i�>[�=�>�	9�$T�^�S>�>��7�м>�����[j=�XT>�y�=�]N=ƾi=0箽���=ɉ���iH>�v>;f>��#�>م>����[�
���0g=#3��1C=0]R=�P>7������=�g�;b�M�Ǿ����]��<�ݽ$�@>H��=�(�=���=ʎ���My>��]�w�4<��R����=�=�<y��=z�-=��>�����=�R��Gl;O)>���!�=��Y�@ؽr⎼s?��w2)>f��;<h=驣����I�/��㋾^�=5"׽�<��4+>N�=a�=9� <L�M=��9=��V���=��꽢�-=�������=m=�=��_>��>�wS����=5��<���[x��ѧ<s(b>-ὗ	Ǿ���=n�	:�=J�l��[�L�%���ٽ�3�=~�>p��>�D�=�Ӄ��`m�ΐ���=�p���=H�ԽE�(>��L�VSB�PxX<�%��5��xH�=��=~�=�b[<�ʗ�>x�)��g_=�����K���X�=�K��M��:�!��=�t����=���<-^���>�d������}���Ѽ�W*�d;��K˃���>r����4�<G<L�ߧ��L�>be�=��=��Լ�w>ƚ��M-q��>U@��􉃽\��~�,������:/=W>1>s9Q��q�<n$>4%��/=��m�ϕ���⤼�*�<��\K���s�su=�\C�=;�7=�P>O��<Sv��k<
>b 3�c�g>�>��S>��w����U*N��~�(|��$=�<�<~��=a�λ��~��߁�\�'>.��>5F��P�=)�ٽ1�4��6>�F���|�#��=�+�.&��h	i= LĽzzܽ��i>e������=�E<H�1>�qJ>bG;���6��/���US�EQa��k����v&\����=lU ;�5��_���4������(���1;�=�;>8��<m<�?��$5�=����a����J;'.����<I��=tc-���|�L��;u�Խ�l���������*����|�,��=��=|�>V��>]R%>��u>��=\�F�YK<ր=��M<Y0�>�V��M�����v��l4�.,��F<���0��=Εi=A�V=u�w��㼖I>��ҽ�l��sc��������=uj ��`���Jμ���=))�;��=������<5+�<̲�=��z�=��9<�*�4>��1G>#*��ң;���,���>�Q�; �X��ͱ�[�=X�/>Pν�+=��1>!�=+ ��ò���o�ש�n�Ƚj+1��Wj=�S=�G��"Z��]�>��X��i>�<y����4�aQ���>�qL?��}=iu��2�����=(�=��=��	��f���R�k
ӽC��=�a�=kxʽ76I�:��=IA���	-=���c���`�=��d<������=�x�<��s=��7<-U���&�>+R>Ʒ�<y�ҽ(,=�Ϳ=-*��d�>���&7�>T�k>μ��Ӑ�������}~���+�=�X=�Z��؆�e�����>1T�p��=��N�r>=��<�g�>$LX;K��rV>U��j{;t��=c�F<�u�D�=	d�=�	�>%F���˰<V+A>�RA9x"O<�N�=�^>�#�=�=$<�=��ʽ� ��@�<Ɨu���f�U� =33|��R��>f<�^&�����0(��\��=�\̼UoC>Ò>Yũ;�M���"νy�=���`�
��2>f@l=Y
�aQ�������N��>zb>�kL��3�=^;��`,>ge=�>�˖��v׽vr�շ\��o3<&��<r��=Ds���8�vh��"�����=�L=ET>(�7>N2�=�{=�P��Y($�ڼ��K';�>�= 4>e0�;:��;�]=�b���8�<��߼x&�j)�=�æ�ˢ{=�[���>(x���g���i>ۑ���D��� ��8P�<l�i�����Q�E2>�Η= @�>��>�#�!�w;<�4�.�w���c= ]�%'���I=����� 5�{>�葼��y��)T=�V>����ΰ=�_�<��L*�=��(�+� >]�V=��=��<��o>��2�J-	�	���~�����>L�~��NI�t;����<�	�â��\�=U[����½���4{C���d=0a=ϻ�=*ׇ���a����P�����U�"��zQ�:�+��́�>7�K>�a��B��7�=Ȫ=Jf>�k<�N�</Q�=�X%�K!7>����k�ؽ��v�K}�=�|x=�48��Q�=���G*���<>��= ���=�`K�K>Y>���=����@U>
�����=��=�?����r���89�
��;��GTm������*=��;8��<:��㻸��Z�V[�<n^=�����xq=�Jp>kn	�"ډ��E��Z��u�0<	 :�G��=13Ľ���=�=G�T��+���#E<���=��d�J�<�5j��>C��3������Y�-���F��<'U�=H�O�<H����=��<��>�eʽ���=[Ӳ��q��6�>�΃��_E��9�i��>V)=�>�==lI��9|������G>P�һ�j4����<v���06��݅=�A��;v车���K����̽�y�<]����%��!���F4�˙�V/>�*�>>H�p�ld>MO�=�t������a�վw�n�j'{��1�FT@>��O9u=!l�m��<x�>4�Z=����<a>��$>>A���6>�a�=��ѽ�[;��B5=v��=?9�=�B�<n5��ɧ!;�@��&]=�mv>�*ٽ���/=�=��=�[�>�L���[ҽ-�ؼa� >J�ּ��1�"E<m�W=�~=�>ڙN������D�=��O�Kt�=�G=*��<^W3<,��������?�C���,��s9>F�>t�m���z�\��$=�{�=�o��x/�=�Xܽ�<�dD��⇽ԃ�<��ӽ�Ƃ�/-���h>QuL=�M�}m���m�>8Ƽl:3�Md>^n�>��6�!:S���v���u��2���Hp<h𜽬�]�證���<�h���m�=Q2E���J�a`%�M����<-f#�/�c���=kq1��9��}7����=�RԽ�yu���˭9���>��=پ�a�U,����_�얀��1H�i��<����=��=�.@��q����>�D>�Y��y��]�&b��@x�=�%=��=V��=B5�<rKD�U�׽0>����%>m$�<"�%�������D�E�Ԏ�g�<T`X����<j4g�]��=�júX����F$� I>:���2>%�<I�K��B�=��B��d�=)��M�=��b�9� l\�'M >�%��/=n��;�4��S��!I
���>����ռ"p�wؾ<�n{��b1>W�<>�<�C->-�=�c��jn�Ao!=�)��D�;��C9��z=��!=����/(=g�U��'���#�Ȕ5=�
�=j�=�N�y[���ė�?_�=(�X����wZ�fC=��<	"���>��=7�B��h齎�>��4����;9���(=���/E�<B��8�	����=�_z=�=�o��=��O�=�_�=�N�U���=���=r��wC��䤶<M�;�)f�-X�����;�T�=Ӹ�<��0>��=F3���N>��9>� ��n����R�f�Z�������=�~=���$S=@�w=�J��2�7>J>��l>Ê��W�J�=����S��P8>(Y���Ѩ<L�=�����4l����U���<�g>P���$�\>�<<�xj�뒍�x� ��A�>��=α�T�=��%�������X�=�ǰ=j�<�=��'�U;�u����Y4��3�k��=#*���u�=c⿽ZAN���\�Q���V5���ῼ�o��G����g�>���=Rx�T>6��J N�E����^=�DG�ż>VK�ZO�"�Y=?8Q>h��ŀ�=�(J�˛�<�7��&�!�aOU���B���G=�R>���ǎA=}�n>��8 �Q�F=��M>14�������>h	>�T�=�G�<�_r��-���=�5e=�44���=�"�<����_0=0��j޽�#�>;8�t����C�:�}�*D=��=�ý.�=Et�=E3��gþ#��M.�=)���<�E	�2!\�D-�>�v">d���)�=����2�Ὢh1=20T�]�=J�gC=8���V����U���9�O�MmȽ��L<�#O=ġ����`�^"���VR=ֲo�q���&�}��<L�ͻ��:���;݃����=��->�0��	Io>���=�b�=^!�=�,�=`w^<�W��$aý�����'��Z=��ƽb�=z0>�����t>������=ŀr�G��J��=�W�=�^��yWM�ȐK��R�+N�H܀>��H>�K̼D�=@QJ=i��}>�.t�����]^�6�ͼ�ag��ň��$�=,H�X�M=�&=��&��݈=����N=��`Qj��l�=\��+��h�q>4�>��<$�r<sM�L�����C<��/>�潶�`=�b#��&>U�޼q�5�ϼE>T�2��ۦ=V��~��9�ެ�=�B9>-T��Q2��]y����>]6��0C����;GĽ���=����-�����p3<@�3>s�n��=X~<(F<��V<隊�������<(Tн�.e>���"!H��r=F��=��q<"CO�(�6=�-U���ƽ��>�߽��F�61>���Z�������3x�s6��l��"n��(Ѽi�!��7��v;@�=��ɽ\�輕�~=?i�=���|��=ʭl�>��=ؿ<=A����=2d=>[�y>��i����}P>G-�<�O= K����Q�����s����3�|{�=�Q =0�߼R�ɽ��/�<�+�QW���<�������<ud���=;B4�O��9�T���>�E��(�z3�m�d����<�=ˢg>48>���9�=\)=�5�=���üK@<W��=�]=�W��օ>č��&�J#0>���i���k2����=��>��؊:�������=�R���Q�>�'��y��$��I����2q��&�(=����>�K=3���`��|!>O,G�i�s>^Z�@�5=�r�=<�>�]E��ښ=�\�=1��=ɺ�^�B<M�<�ɱ�����'4�J�9���;	!�=�����G�G�e=���'�3��]���F�z?>����5�;���K=^�4��9���/�V����=�v�=Q�=?{�%=�!�=�M齋�ؽ�j`�1읾o�>�PT�s8���	��,i=�{�;�z����u>�����-������ͫ=	��=�Y���D��Aq$�/��f��B,��N��ä�;��B�Z�ν.�_� k�<��c���=aØ=��I>�Һ��E�=j>����`%>����7�ag�>�o)��E8��b�<�q">��C>e~'=q�ȽnŌ��|��,��lC$�G�.������|<��:��=���0�>�a>EBa>a�>��"��ݨ�#�ڼ�3>�fʍ��ا=��=�
�<����V�=���=��c��"�=�d�=���=(��<({^�.N�='<)о�	���%����=]L7�Z���t(g��>���L=�G�J�鼶뇾�������=�@��g��~�P>0�g������g=Cԟ�#�`�&��>Z� ��T>G᤼�<���c��7\=�4%����=J3N��l�<4���4zR=���\.��mS��_̻�mR��j�*ѽA��N��<՚=u�ؽ��c���S>��=��	�@~�=��j=�1<X�1�XT�$H��	�=Ѧs����@SB=������ӼT�>Bv�l��=�V�=�L3=�߂�n�U�ƾ���S��������ξ�Z�<r>̽��=͵�=�A��]9��c&>���=Q��=�H$�ؘ�=���=�#Q>y<�����!���%/�i����ɨ�v�[��82<����Q<Fz��j>ؽ�*��=���yYh������A<)U�;R��weW>�H�=Mݽ����w�=��|=��=0�=9��>cN1<Y;ҽ��>��O=�L�;zNE>l�e����:� ޽�R���@|= ��=�>�=��� 7���L��������v`>�G����ڽz�i>ҥ	=~e�#ǃ>�ՠ=F�$>`�]����>N6���l=u��F��=K:��'��<Gن=����"���S�=��=����A�D����=�F�=�.�����3=�9)=�~���>ٸG��ҽ��4�0��<������������=� ,=�=�<2�\��z�q��f��=p@>�ST>�!>B��L>�x�1�u�(>U �<�L2�}��=�R�S�	�Ijd��ޜ9B�=������<p�1��?"��U����ʽ�����4�W���sV>Bsq=w�����̽��=X���V��4=���K����'=J�=7H������<��=�7@>�>*Y���ݽ��ų$��?���>���=���!���<�=7
f��~>q�<!6t���6>܀=��=�x�s�C�_MT��咽ĩ<-)>GL���A��f�>,�E>�8��/�=��ջ��<�~b<RVֽ�P���Á=���� �<+�`�����*<�������d=��=
y0�A�<g=)Dm��|�=-ν��_��8>���m5�T/�ե"��@ =8���D��>�H{��\>$��	Tk>�2�>UD/��w�<e��
��r1��c�=$���)��A�>�}�<�u���v<�3=!���v��=!�V>�8���懾u}���O.= =��!�=�2��ar��؜>$�M����t2>7���>�=�_�=��|��$>hI��»:�腽I���
�j��Z[>)^�q�w=Z�h=�e��>�5>J�����<��e=��H�Ʒ�<��=��.�������=�P���=S�k}�\��=X=��K��h#���<U}m�=�
����=%O�;�*�C
n�k�y=R�>9̽�꽫�[>op>J�S=^Dg���z��V��kWM>�Z ����=����}��Z5�=k�.>j�%>V֏<�:�+~.>��X=��<�\H����n�>>��0��C���:�p�G��#>��=iT�'�1<�d�#=}��o�=8y; ~⽷��u<\=9u�>l��>��=d.�=�L<��`�=�2>�wG��VR<\н�cM�V���z l<g��=���>&̛>��7�=F�=$'h=�P����o>�Al��4r�w��=)K�ĺ+=� G>�Z>H!�=��=2u>�e�Bܽ�8�=�����7>G]A=n���t;fa\=L�V�,5k�7�d=2k�=�J����=�|�=��<��|�L��>�#��H~��>���m�b>������<�wk�D��������%����=�a佋!��T=��Y��F>"u�=)�E>�}2>�'s�=S<��=��g~	��p�<Ө��?=1V�ڲe=O�������!�=��r=�h���ƾ%;=}�=�΅=	��cB>-E��S�5��M�=d�>�����S��S���=���=�l|�DJ��B�D����<��F��/F=�d���<��X>�����Q<tL�� #��A����/���y�=�l}�a���Nz��͍.�6T��(O�?k��Hs�{q=yJ;=L>*�#�r�D�;�c=��+>qN�>�| =�䪼೉�Y4h���<Or=q�=��o��T>��
��>����Q�9=Jp�=����f��O3F=!"�;�l.<<�żr	��2�������=:"
?+�&��*��m������=jc�=iC�<�� <�b�=�e�<~��Pp��9�=�i��w����=D�]������<63(��g(=6�!=��<KHĽH��{'@�zӽ�~��!6����v���n ��P�C��==(0�4�->.��>jhp���^>[��h�;#Ƚ�ǥ=�5��v��~����>g>��B=��`<��!=4�^���n>�mڽ�ܽ�`@��xG���v�{=5�b=�(>_=A�ͽQ�<�F>T�=���־�=*��=���2HW�#s<�cd=u��%I!<f��<��=�DZ��v�<�_g��f2���;�X3�քX=l0�=�*���=V4�j�>B�=��=D�>��>����;a<��O�&��N�=}�=U#0>�����`���4�9�<<ի��b3<ohF�O4��r4�=l�>�&�޾��!1=�~<���нx�D>�E�=r�����ɾ�Ҏ�vv�=����!=ʓ��i1�<cf�<\��b���L�I���(>�ݢ=���=2�M���>#������6<�'�=N��;�˗<ͽ������=y�=[�ݽn\E=h<��>&�6;h� >�<T��=�t �`}�=�����=��	�Q���8f9��J]����-�+�6�=qg�>���_�N=��0>s���G]�=SH��0�܌�=hr�>�V>�t��XlW� �=Ѭ�;���<�ב>_A���q��a��yA=�5=�>��=ʭ�����cF�=�m	=+�T���
��_�<T�)=PY��ѩ��99<>�;�M�S>����&��E=n��=41==C�h�~�=\s|<Կ�=U���d��[��M�=����1�<�[>���=��c��\�=<>y�<��=>L����qE���=f��m���٩=f��<+o�=`Q�=Iӽ	�����'>���<�y%�P�@��"l;�s�=Hy����+����=y�=����{~�=�aӼ��>=Ž�Ǖ:f����Ƽ�88��N>�hQ�
�K��@x�|9�>�"�=�޽�rq�#ӟ>�|��~��=�ϋ=��	������KL>����@���Dh�9�����=�8=�n>Ɯ�=��u����<������=�ǫ<�� ��\�>O�l���Q>ק?=夼rR��cI�=�ܽ��X<h-#�YO�y.,>��<n<^��f��o=������=������h���>���69�t_=#�=�m��P��=ֽ̍9:Ѿi���
=|�Z����:�I)��;/;�z��q��䵽�N��g���L�>!�s=��>z�;�]��A�$�hG����=(]=�ٽ�lM>I�K�=vnP�zi)�8��;�^�T:=F�=���(����/>[��;���� �V���ѽ�6=���$����o��V���"�<������8�K�=�W=M���BM���=�{<���="0S=��>�8��f�=��ཚK�u�=����s���W�A�@��W�;�輼>��<4�����v��i�=�o�����?v=p��<W��pz��S�7��="�+>`3�=*\��ԯ=�����">ڽ�;���h�<}��=�q���!�=��>�'>��J�ȓ�tz�>0�>�{�=#�7<��<O9>�D>3ȟ=�b���*>}5#::[=t+�:|c��ϗ�,+�>yܩ�+2��%b�^$>f턾�G=�F`<���=|���q>f�=֤���J<�'S��A>�����9���=c�0>�\��������=�9%����=��>]���g�ʚ.���j�;�K=�7�=��V��4
>�ݘ�rF�<u�3��=�4_;�:�=�+=�+���J�>N>[`�>�����ً�V��=��\�����T>�Z3�J0��*�=���Y3�= /ὒ��=Ţν�E�u轁ug=�׆��d���,���[��=�����C�нO>��Z->��\>^��>�:��=ِ�P�%�۠H�X�>�k����">	�ļz��=+l>��9���=�f����Z�3�<~� ��=�<�]�"02���={੽gA�=�R�<���d��=n�T�:�μ��E��\�����=�B��8�<������=�# >������;9Ƶ<{J
=��8� S��))=,������ ?���Q�/�0��'D>j��=�^&�aN��,Ľ���ݙ>��"���%�I0��.v9��Ľ�(�=�ȅ<~�	=�:��L����=�>ҳ=&�=-
�=>ڢ��]��ӷ=�T�<:$w:_ཏm��"+���>1��������H��w�=�R���R��-I=!v7=�.����3>��> f��a�=#��=O���ܪ�;�{��#>����d����0��T�=>���P�ּMW��o_=ue>�uy>Le�= }ڽ���=�4��_=�K@>��q���H���7��V/��;�y�=����z�!w>��t>̕i>�HN=&�e<�Y<�JA�Iʕ��<=,q#>��>Ű��t�u5n=݋S���D>=�4>zM���k��ǽ�&H����;�����=��=q�ͻ�a���9�<S���}�>X�缤����΁��}�2"n=A���L�<[{�LCZ>��5��>����ɖ��v����=��>{J���w����%��=*��֥�m|�=^�U�%=g_���>�?�=���<:�y<�c��=�,����T=%��=�P{=[�=hs	�|���R҃��P�=�g�=)ў��H_=8��j����5=���=:~�=�����#�>@�'�k'����$��{B<-	x��>eC�<�%>g�>����z;>۽��E���>�>��G��+U=���5�UDY�r��<f�l�P��=��~=���_��q�=�{�=�Yཇ�<����c<6	G=i�y�=���9mܽ�>uh�a]<Lq��ુ�']m<߂.�*s�=���>C���<�=o�;�~�>�F��d6d�y�������>��>�P��ϊ����=�P>�R���2�=��������w��&�;��; _�1"�=�<�f>\�������q�=}�]���r�؈'������É=[�;���ft�=_NĽ��=�:_�<��l��� >Xk��7��F�>ĥ�<�G�={���JG���&�=R៽�>X#Ľ��������;�Y=���="L��o �q�^>���5��=�Xx�k.���Խ�(��HB�#�t�a�>�=s.?V��d��=��;�t�<̒`>�k0����؄����:�T��f�
��������G��˻Z�.��=4���ռ�)<�i=4�=���#a+�Fc����M���>S`�����=3��<$M*<Y2=�p�)��>��m�؟�=�����=�h=�~������5ŽF��=vN�=ϖ$���W��
 >y0J�s�*�%`�=	{%�Y�=��c���=�YѽE�>���P��N�]=)ѥ=�/��"���8��̌7�G|���V���n�=t�>��=B�">ѐ��(3����#>D�<�H���<�=4;0:p=YiG>��j���<�å>i���D���=�-w=�
.=�����^*>S'���=��<��� $�������*<�Ё=U���35=5v�='��d�љM=�:�C���νLS=���U�=         �V� >Vb.=8}>X��=�f���oi�g �>��|=*�<�j�Z>$_r�(C� ���1���ݡ�W3u����זν�=      �ߥ<ʤ���Ž���`�[��@ѼQy�b`þd�[�8�P=���Z_�����=ҵ���Щ�B�=�I[�=����n�>F�C��b�=����A����`O���龣Z%�Q>ig�<�F�dc��,8��O�v=]l3=ւh>/l>6�>��3�=�w	�ͽ>��>zj��˒{�S��j��=>j�J�=��H=�.g���[������	��5��Ř[���;<Po<�/�ka"=RE�=�V5=�d>��>W�"=��J=F�^����=�'h=�I&:� ��+�=�>d�3<�v<|�jL�<� %<G�n���b�=e�=E�5���{����=���� �=~eڽ��!�5g���'�S���9P=�92��y>�T�Z>����29�=B�F<L��rU >K����>2�*<�oK=�-�;1�/����:&~��E>�M5>��?<U��<a@>[̝�A/�=�ɠ�+�^��}�GF�;��r���J�=V�?���߽=e�X�f�>��o�����&��U� �K��<��廬9�=|,�>hk��_L>iM�=�0���b��W*� ̚�`ɚ�,ʄ��	���N�=[ Ǽ3|�E���Œ=QSM>���>��?�%=û >�y�씽.�=W��P�=������=�V��������=�r�<-r� :�:";��]"<v�l��@���&=�f���ȲC��Z�=j}Q���=��=�!�WV�1��=ǆR�f�l=D�n���;�̋=��?>�G���V���>A�N=�I��w0>��齒����V=ϰ�<����栽(��h�;����=
y3>��!�<�>���<���Q���>˕��ӽG�G��)�1.ĽzL*>�]�>���$�<}?���<?輽O�,�V��G۽�t>��O��^�=+>�	���3���ΗD=�1&�~ ��3B��� ��A����=O�=�bϼ!����s�J[q�."�Ą,>��/��4��	y>=�#�=^@=�%};�	����A�)B�=b5�M�C=��!��;۽��	=%�սx5=?2�=�@�_�:EOD��T��B����H�;��~π�N�����	,<&ů��������=�'="]�<�Vz=iһ��r����<KD���X�{ڽ����S�ܼ�@��㒩=*�!�s�=�Z�����,
�k��>�4��`$� �3���[��Md>����E>l�j=}h̻ͣ�<4/���S=�s�<�$>�e=TO�;Ԝ̽~����{��z =��,>!�a=مz���v�uͼ�>�t:������" �� սΙC>U�޽ph=xTv��br�X�+��yս(ѳ� ����<�t��؉���M��Ck�=�j���^9غ⼃��>�
ƽ]�;����t��8X�=�bŽ��D�#9s��h�=�������HF�Ca�=��}!��л�&��7����-���=�W��`>Sѻ�0����O�F�[���d�)�0=�v��e㌾g�\>v�5=l�j<^�ͽ��8>��;�쎄���Y=��ؼ����������=<q>l��=#�ؽ3�<zv�=9�g��W��Q�<w>?�tY��]g�=b� ��2$�
����T���T	>gN�jP�=_��<t1�<:ټAp�<�F*���=��=b��=�w7��;:�d��c@��qX�-{����+�5�k�&��<��2=�;	���-q��>����<���?S=dzx=ѥ&�k�����<�;콹r���۽F�O�$��>9�=Ԡ�+����7�~��>C���)�_��&$��:��">o��H�5��J��Y���Ľ�M�=�o?>��'>�H:=Z;��9pν�챀�mV}�A�=�Y�!�=��"�l�1=8٠�ʮ�Tep=/ �=��;>�a�=kہ�����v���܈�p�Up<67��n5�{J=��&>c��=���<���=�w�ϣ�<� �#��>b���1�>9��=2�<� B��#=Km��ε�������M�=l����<l�NJ<�I���˜�c@;>�j�=�\��"�
&羧����M���1׾:_>y��⟁=6��<Hh=fy8>q�=�� � �l�T��;p`"�� ������=�5*=�Y�A"��j�ypʼ�=�4Z���H����=�~��o%���D����;W��4<߽���ʽGaB=�$��X?N=�.��c�
���.�^��q1�0��氹=��$>ʫ�=_
�=B�����=c0����r�=��t�'�> S7=o���=��<Y��;5���)u���>�f|<#炾I,������g��F=�/���i(>�ȽD�=������;�8�=��%�V�>��A��9��>�A��	=[��[ٽpj޻�m^�8|[=� !>�* ��1��ַ=�=h�����)=��-��[��ZY��ɜ������2��-��<�#亏!x���=lA�=��X����=4�лn�u��R��(�8=`�1����=k�A�9Gy��C�=���= F�<D��b;��z:D��ǽ�7���;=;>>¦����;�úG��=��� 0�=���X��i�]>^����g=N�=}�>z���*��7Ҧ=6�/�j�e=g��\�&��OG=C|�>����޼���=O��������H襻�n�<���=�+a=���<(�ҽ�{����1=��=�_�=��%�T�>��(��9H>�3;�{=J��=��3��K����`���>Kfվt���Ծ�7H;��	�=6p�.�Lց�&�6`����Z=I9Ӽ�Qr�^���J�����;�t>tT�=i�>��<1Ey�i��<��<�������;���)�q=�v5���N�8->���=�ߛ�3�B=�d���y]�������������D>/!>����)�=T ����ϼ��+�d�%���>��= =����٣���x�>@�'��)�:.�����=�t�=�$���(1�U���x=�G�>I4�=A�a����z��=	J+=�{2=!\!�1խ��J��[���S��8�]�r!��>�"�R<�)�`�����s9��>>o[�=u��=�͟=&>����+�>��	jM�{F>�n�;��=�ڋ<�fw���o����=i�;�Tq�Cŀ��L�ǈ���W9��f�=��¥>�AVG��v�����"���fΏ<�R�=f�����i9=7�뽍�D=xPz�t�v<@Ѧ� ��yWt=!�ͽTP�(�,�9������%���=Вu�d \=��۽���<B�}9w��<i�t�H�g�D75= �^,_�#���>dg�%�(���>�gƽ�`�YZ黥6�<7n��7�=�I+>C�����<�D=��	>�z�Η��#�x�1AC=&��<��=�A=@�<q�$�R�轪d>>Y>���g<@�k<�*�=F�>�sa��8A>�F��	?�='��>�c5�^?�=���Խ�o�;F���->�Y>�<<.�=`+��
{���u=�aw��9�=���̉?���s:z�E���Ka=Z3��X�%>�+�<KĽ�Ӻ=��P����#�=vZ� (�������O7�l���r�Պ� a>I:�9z>>� ���U<y@=Ψx��z.��'���?����=�a߽t=>r�\�:�e��j�=\�>|�輓Z��vQ>ήq�09���9�����O�#l�;�ԃ;��=��f�z�n=���>����4l�!��=2�>ق��[>&��|�ż��s=(����W����=�f+>.F5>V*>�j>QcD�{���ڂr<�j�U�>?0�V_a>�>J�q��<��-��=�p.>�>�u�SRr��"����WD���=��u�Q�J���˼[.z�ç����I���B� �%>I$)=�H�=gl =>��<�8�"�H���ѻ�-|<nm�(cK>X��<��b���.���V>%M�:�$�==���� 6�*=>M[���=�{˽���:��=$7�>����S�<~,̽��j�p� 8�==�<֭�< X$�����wz>
�=�
h��I��jx=�>2���}n}=���;������;��#�X0��pZ�<Ͻ�9&���l;��H������]��>|�<�=���E���=d��=�~3�=׽�k!>dĽ���px�����Jz<z񵼸湾[�#=9^��щ��b:���м |s=�\=N��h����<��i=�<tǽ2��2h����|8�C�N���,��4���~��
�=%ѽD�gh��n���6��6l⽲d,=�b�=Tdu�>���
�^)Y>�-W>����?	=��,�4�=�)�=�=S��<�d�#�K=�8�=�j�����MP<0=��g4��f�����zy==�Ⱦ�f�=	�=LT��ȼ�mC=
˾ƪ�S���=�69{=�	�<{�H�d�+=<�����e>�����	���&�B<�=F砾����5�������_^=^��<Σ>�B�=�g<=>�iѽv$u<���f��V>*�=>ç<<K���lM����A9�=V�;*>AX5�T�;��O�G�=���}Y�*��=虞��)t=�=����<$�!<�*����=�2�&Ǖ���2>'a>����'��鸽�d�=U�g=ױ����	����p�Ž������
f��N�=�O@�TOY>I�<�0t��qF=H�������Z��r�=UǼ����h�͔(�1�[=آ9<� ��ޚ��˥��N�=�M*>{���~9>����=/�N�/C�������8��o9=�=r<"?�=��~=Y� �l������F>~��M.��r�a𾾸��=@��=�N=<WN>:�
��*>Jl�G-?�- ��=xA��y�<-m="�ֽ�;�s�Z��줾"�V>��;Do��n�g���Z�Su�)���x��<o�ս���=qҥ=f�:���R�����Δ=~���U�9����]�<9Uͽ\��=bc�=N�!>�۽��=��پS���l��������?�>���JUG����[&�<t ��1�;��=<�2=�X��1>��=�&��+ܾ���>xvt���n�\�A����=�(���j6�A��=$��>�5F�6m�=vz�)��=�a*=�M�<X��Hrk�C�ʾ����r�-���j��v����=���T�_�X;߼X2
�����=+#ºv'�ı�=�_�<v�a���۽�����}B?�)�>g�ƽ*���`�2g3=2��=c�;'��u�=6ޝ���K��v��<=[�"����=�=��N>F�<���=:�=������X=?G�=�7��c�=a�ý����;��"�������0��b-=�Ȉ���<���=�@��dY��9<�$<Ñ=�>�m��6:=���?���@�����=�v�=L.>ni=���/+>uc�Ոz��u�X��������;<�>�̣�[�Q�(���_{=�dA�&�e=��C<��=��)�����>?���G��i0=
8��?p'>>�ͽ�9J��[��5Խ,� �����Ƀ��2�=��`�5�s��<ν�7�,)=�B�=n�>Xd�>$x�>�����>;�[>&����b�����<	f�����#3�{������T�g=�qû*��/�q�й�>�J��K��Q=J~ؽ��>�(&>�㕻uV�=-I���R���5��V޼+ϼ� >q�<��>�"{|=�
	>��=Y�*>L�o����=v!V�b��<�����@/�Hv7>30H��+���,b��X =N)=��c;k���)�Q=����#y�=A�D>��]��z��C�<	nk<Ϭ>�U<��"=m�@=֮?>�Ԅ=.Ir<Yʀ=!wI����>M�w�iB�����>\4V>�'��j��.`�Ѩ�=�/H>���0�Y��	 ��W=á>N��<�?U��;!��� �>��=��C���Ѿ�!�<ڱ�<�� �jj2=�R�^R��%E=��#����=`�齜_���y�#���?<�U=#��������q�T �=��Q�^'�I��=Uu	>K�G;�=�U���¼{3�=�T	����b��=˧��"���Ӊ�ϲa�����=��>=B�<��鼹�4���=j뱽���#>Q����;����>]i#>P����=귽 ��=bD"�����4ۼǜ���	ǽ�ҽ�:��o<=��<]T>g���ex��+>Z޶=��=_4�=�7��o�>u��=\�<�<ާ���)g<U�?���>�ֽt�]=õϽ6b;�M=i >!�T�l�>��ղT>�m�֌7���O�ݦn��}ɹB���p<e�־����*I#=��9��q	>��B�����a�="�Mp�q�"��4���'>�=Ͻ��=Rv(��� ����></`d�P����#��n-�;1�( ��~�;%��>�(�Si��k��V�����>S��<`?7=A+v���}��R�b�;��²=��=l�T�G��ۼ���P�>�j�=�-�8�=���;T�|�<=,H6=C�<�=w�=D����^�=�`���p=��ؼ�V.���z���A�_��i�>M�����(�J=�=왮��û;�>�
m��
N���s,n>�i7>lU�Ӽ���[����<��� ��M�7>%�>�e=���O���|�J<��=�Z��ߛ'=^Fe�'T������{�=��!>�(�>��l�c#��y$>���<2�ɽ�J>�&��`�1PB�O0�=]6�<��:�Z/_��ޠ��>�����e>
>kO��t�a�����;���=v�">>>*=�Za�m8��nu�=���;�]�=��&�$�>��H>?�g=4�8��ɹ=�f���6>b�v�)�=����*�Z=D3�V������;�N�Zi�=�;��@��=�;�=@g=��>\{�=iMl=��A<M
���߽g��=�ʊ<2�>�b�9�!>?(H�G!B>�l�ۚ>M�\��2�<�ە���h�l����׽�O�=�D=��t��21�&��=��2;�)�=���<�C̽�]���=UcĽb�\>~�=W��<��콩�@���O�;$�<��>8�e=Z���)K��ټ=��`�I#�<r�=�cʽ�� >��<��>=*]3>"f{>d�&=uP>�ُ�&.���;�=�C�=�g�� �/��������=���=<O���-=eK	>�~�<�7�0>B��=�V����</�j�̾��&���޽,�AmS=�7w��۹=%�*�ž�-ֽ��=q�����Ⱦ��U>N��=���C7�;$�U<��>6��@���N�������4�MD0=���X���J���z�k�=���*��$c>���=�y)�?\�=���a�A��љ� `H��ԉ=֟O>, <��j=�!�X�ҽ�ӽ.���_I�޲>�Y(�Q����F��:׺�O���>꛾���7�I��8�>��\�E�j�L�N=x� >�Pe<�Hr� <>*��="�Ӽ�3�=W�0�0�5��X-=oL�9ǆ�c{�<������<E�w=���Tiܽ0'�=�D�=�ai�`�;>o��=c��<�}	�r�Ǽ��J=�}���t�ہX��\��f��=��ϼ�C>�^d��f�qܬ���n�}��=��M��nǼ� ���˞;���<�p�?'���X���=�&>�=~�a=_^*>�aʽ�=����*�u���佑"�=�(�=CP�X8>�_���ۅ�67��ؤ�7���Z��	�=�;�]f���4�������H���!V����=�>]�{(=�cɽ?��=&̕=�T���O>�S4������J>-��=��C��--=#95=0�=.��=���=p㥾`>2>�yO�x�þE��n`��l���E=0�<�.�������=:���$>�2��VĽP����<�=�̻���#=�]�<}Ͻ;��I=�$�oYn=�S>����H7�=L=�3	�z�ƾH�1�٨��CȾ�@�=�H��7 a��ּfʽM�_��[��ں�ܴ-��$�咈>��z=��=�p����=�˼�^�=l�x=j_M���Ͻ�lQ=�*���<�=�
�>ij�;�Li=�ux>N���,.�����5��=v��=�0�=El�=�A�޾�&�U�<44>,=1i���5��O�S�<�p��j��I�=h�<K��<��u����=�$�<}f>�FY��9���?�>;��<3@�1-[<I��E�D����C~>`d�>"4ļ �=_X��X�i&2�иý�m<���=�^�<~�1�R�=	�ռ�(��XC&>B�ս 皼:��� �=a[��O��)�Q��=�Z���=��>�Z��ab�����ս���=���<��>���=�[���sC�ƛ��l�'Kڽ�
}��$�ao>�uܽ&N����'6o>oqƽ�h(���M>oU�=�1V=��>a4 �&g���>��=�|u�!���w�<����
�Y�u9�~"��X��:!��R >�R1�H�&�v�<u��P`�=2���E&>�b��j�H<�������i�����,�r��;�J���μ���3�-�T�ͼJ�N<�t��&��<Z)���!<�ו:Z'>�����>�;S��;k��<xo�d�<�͌<B�����[�q���Z���^�`V=�=5��=�5��=\����I=0�ڻo=�\���`i�l&=}0�=W�;	9R�}��/|<^4�O0=�ှd��=��>�A��p�3|���`�w><��}=�?>�,O��*׽����w(R��fI;Y[=�g>*�%��o%=T�����<38=^9 =ۦd�_�
>�v6=,�=p�w�0Ʊ� 祽�ɐ��ؼ=�����E��c�yx��1����i>�IS=�DB�t_���|ٽ�}��J��ƭ�A)����,��>���=�
�������7�x���"�<��>����>i��=#J>_�>���<�'#�l�=s>9>@oL="|�b[н�������>�2�������=�[o�ɷ���i�=��@��8��Ռ=l��=�ei���Ⱦ�Ľ�A��wM>^&��op���Ƽ��<�H#<�s��vx�=(��l�� }���/p�^�����M���=��_�=\ӆ�~x;<����m�>�c�F:>w�>��=�┾[kW����h�EΚ=��2=p�K���E&�<�ࣽZ�9����<���)�=�@�=�:f=IZ��!>%�˽�[<�C>�I	>e\��.�=�{���<7�t=�>>C�<Z> �3�<#Q�<r�<\f�:�߷�����tU������8VQ;�H�c���.�����<t�>��f���=����'=0󵽐f��e��=�����B>ӈJ��i�=�Ҟ>��<�҃�ֱ�<w��=C�C����=X����Y><�A�#��I� >�����}=�]����=�b�B^�<1	i��&�=%r�<V�H=޵&��(�=#�O��aM�C�]=J����P��>��j=�l��3��	�Y>�w����>u3U:�3��0*�<��_�Y"���&>v�(<�u=d��;���jn�bSڽ�/�w(L>9������=Z7H��;=�o߻$"==�>����X��=O>T�%���+=��p��ki�'5O= ��=Z��<rǸ�6<l=��iL���>^p<T漽���� м3�'�%�E�ʠ@=�O.��=�@3�n$�ӑ*=�=ν�A=d��@��<�u�=>�V�=c���YE^�⏹�$�{=<���5�=��F�	_��t >�������7�e{ɽ�z=Q�[=��=�o��	�@�ܽ�D�=̚m�.BB=
��;kc��.N����O=O���Å)>[�t= ��/�>Z��> 3>(�ʽI"���=FEɽ���<�����p=��r=2�d<g���S���h� ᔽN睼i��<��=n/ ����K��m���x=�qԽM�e=���7�z'=�R=k_ɻ�
)��Zx��A����C<D��Sn����F>[�:=R[>>��c;�$�<�kL=��
��M��^�+�h/���U���g@>�C�<�$�=i�ν��x;�OB<RT�;Չ=SÆ;��?�Ԁ*������_���'�����>�O���"�������~���,���>��&>!�N�\�=} �>"ą=V��=�}�<��==e:�uj/�hf���_J>�A���D��:>��>��=n;r��W(=.�>xޡ�ᝨ�*8���b��C{���R�>_�	���=��ԧ�=(U��^=�>
X���U>v/�=��ȺG�=��������� �<����sx�b���W�ռ�,=�iμ�uj�_1M<���=��<O�U=K @�A��=Q-=��ټ��LW�sh�=1�0��o ;/_�"�۽2T=�e]��Ay�4yi� 5>�S�={#c����GÓ<W>�=;�=ͻ �F�=7�x��_Z;[c�X�\=�` >*��=c�k=�J8=�~ͽ�������@�=�-j�k3X>��=AJ���>��7�$b�<��#>:�b��ߛ�=r���G���y̽%&���꥽��=s����i��#�=z��a=��kX�F���>��K�ٻ�$c>���=�a>�w��,�̽�齞r'=J3r��;~=K`=��ý�5�=���=��6=�¢��e��Y>=��A�R�����>�M<��9��䌾&Ž��쓽�qD�Q��LT�<�d�+x=y6>k��n�ɼ�l>]Ž�|H�V_o��������)2N��P</Cj>]pv>�N�=0)��Φs=�ڀ�7"��`��<��W>٧>4��<h�����>-��=�G˽�3��E��ƌ�=����i�����Ma[���->I����Ђ>N27>x��=�(��\�=�v��<g��./���>04>�֗��>n[7��1�=*�$=�w�<M�b� "=q6��e޾�ѺHS�=�Ӽ�`���Y���>�������lY�u�>��'>��F|��I�7uv��%�U�\=9ک�B��<41��=H>&�>����8��6q<Wfk����v>��|=ꁃ=�����I��ϒ�<c�->]W����<ozS<W���r����<m�=q�!L'��!ӽyoM=�2v=�+"<A7+�
Pн�DԽ2�>�_�<1�z>��=i�==��6��0�=ي�==ϠF�U$��ܺ��$�<��9<;)���
�aRM�\L�=�R��k>��=d�z��	K�)��= l
��|@<�(����v��8��clb<�d=��C��=�,E+>�X~>2��|�F>�+߼��<VN�~��7i��Pw�����'=Y�ڽ,6q=��˽���i{c=7=��ݳo�w���W��=L�t��佟�"�>�<~/E=^^�`1
���#�t�
>�f4����m��<\\���=>b4���(˽�F�=�./>��׽qť=����q���%Q�)��;�>޵%>&������9ͻ�~>M�����~O�=�=S�?��o=�M����D�q>�R��Ȋ=Yؑ�
�b>Zn~���Y<a��=)�2>14p=�<�U�6&�=߮�=[���E���=���L��<\Rڽ��= (���;<_6��	� �|�	�9�kbK=u��Ĭ�=��>&�n���>�q�� l>�>c<����<}���K���㉍=�h=��&a<����~��<��(=r<$9��� ��	2�?</<��(<x���]�1-��۽ ��=!.���"�=�)=��̽ٙڼ�1>6��2C���?==-�=w/���❽{�ϼ�I�=$�>̾���K�*9輟����<����W�|>��Ǧ���3� *ٽX�2�ҙ��ln=�MF>__ӽ��3��5��Q�=�/�=ݵ�;I"����=�~j�Z7ɽ= ��g��敌��);�_>�m�#G�y�<���>�ܲ=h�=!�wm���<�]!>�Z�8oy�����`�=��F��?�=-�|�	�����=L=����>FC-?'t��
>�<��l���J]=�>����G�=i�Խ�r��\�=*���A =���pn"���ѽ��=D@����|�V�=�j9=�dy�0^�=tV&��f���|f�$��=�J���A>���==�M>�,����< eq��|�=����Ӽo��<�����DT�u��b�Ľ����d鹽$��=�Ct>p���S$��Z�9���S���@=�ٽ̝B<~r�=��=n�8�F����	��LD>����譂��;�VpR>�%:��������6Iü��ὝJ=�Q�=�IV>��8=��r�S�h�&Iv��	"�RN>������N����=Z:=y����Q�9+v=�Y���[$>�V��,�>g��ϣ�$��]ȭ;(��=��~;�|���-=�Z=�L��m�e��F=%�=O��=bg�<���.���Z�������J��l�νX<N�=���<]���[e=����N�ݼ���=��=�0A���}��5>o0���ƕ>�ĳ=��=���<x�����1���C>�0�����+��ud8�248��T߽��5>n�B=�"��#��xm���/=���=	�D�k�5=�YL>�(=S�<�s(=�슾�Ɍ>(�����F�B���	߸<@Q5�cn��
�Z>���<�{,�מ��p>�rJ�����GZQ���a:x����{�:�5���E����</�ͺ]�<��W��ʭ>��4��0�7��<0%��Y�T��l�����;��;�?=Cn7��f�]>�=MOa��x1>O��a�=4��=�׽%l�=[)��D׽+�T�9#�<\�����!�Φ���ȅ���7�-s&�֬�>~�Y[&�U�Խ�����FսΆ��;s���^�Ɖ"=D�=+�<�X!�@� q��4����;>�'c�����q���!�=�$�V+߽/ގ���&=���Y�=���CS>�z��҈����6~��۽�*�=�f<=��=
ġ=�f~=���^|P�:��<��%>� <t%�=���5�F{-=]�i�����O߬����ݍ=��;�b�=�n���m�=?G�'Kq�~�4;?�>� E�D���+>�ҹ�Zӽ�����&�����<ˡ�=�^��5k�UJ>�&�*�>=6��`�D��ۙ=E
���w��r>tH�=Uq�=(�����Y��,>u?
<�O>qؽ=F�(����=˒5>Y*>�z>?B">�W�k+=PD���ҹ=��)�	P�4�&=$N�q�O=�<�٣=5y��Q� >���=��=��#�>2�=0������">�5�9E�=n��'���q��=����<,ּ����T�> g��V��F�B�h��wE>�a�p�">�6��o�>T�>>̽��'�<�;��A}���ʼ6�O��<���W>Fe�=Ц�=qk��ۀ�=��T>�����>�ϩ����A���`i%�0����6>yO���>���Y\>��$=!��=�\��� P�z�=�ü��0>�L,=ɶ��Me�ѻ�������Y��
���;>���3�:��w�i��=��3=E頽�~��L��zЭ<ܕ�=mW�+�f�|��>6��=m����=5��=��O�++>25�B� >x�=�d-> �������@pt=�3>�z��W�߽5���\d=�m��ӋŽe>�[������<���=$F�����a�+~��5?�5��>Dx���d��o�=RC���2�&�z=���4/�=�5����=D��K����_���m��7~<���el���=���$a�=Ο,=_v?=��W�=��=�g���U>�0<=x�>�]��r�>�PR�x|��-��t��v��H�>Vlo��(�������k�F\�t��R��=�����~��/��h�<�,$=q����瓽s!��SG��5�d<ض���/�=w_���=e�O��QC�{����`���޼<��*>�w����+<J�V���ý�#���=c�	�8�$=���<�e�=b .>_=��vU>v�>�{>��6=��{>�=|�=���=^�*�O���(w����=뚎<����&�<��+�7㴽�O=<�'>�=�K�����_`V=��>�3>���=G>���7>ü>dV���k�lp𽇮��/4�ȇ>�:���f�}�J���"���a�yb���F1��۱=�ڣ���=��
<R�����<ts=D�'�<<!&�=���<��l�<�6�=MeO=R��=��Ê���;=�e�       ӣ�?|΃?ﶇ?�r?���?��?���?[O�?�x�?V9{?*CM?0'�?Gm?��?�v?���?
*�?t(x?[�p?��[?       �f;+};݇ :>�:2:���:
Y(;��;��<���;�5�;��%;Wh�;'إ;�
:;�I�:�t;��4;��:3�;       �y             �|=��$��D�<��S<���;�~Q���>..��.=>[�=fc�=ʩl��c>��<M�G=R=r��G->��齌�>�f�       �y             ����	,=��Ž��=>����7=->�)��n��=T_�=�=����=VV�=�(ѽn81=H��<�>��_�8��Ț<o9)�       Ѝ��m��C��*�R?�c'����r)���mW���,u��xA��"��W������׷�=�rǽ�����#���>��       ]�=K�ӿ����sF���#���}�Y�/�^S� 9u��᡾*���-ȟ�(=g��=@�ǻѿ�̄�pJ�S���]ը��&k�      b����6���=�U�鹐�O�=�u<�p�����_���l]=(=�6�ʽ����=%�=�E��?�>Υ�����P�F��I#>��=7"��� >�r�<�>�׼���*b$=-a,��L~=�}�����:���fr����u����O�y���Y��(�=���=nR
>c��>� =D<>p<>�!ѽr�<#5N=b]�gM�]I׽�ʆ=EF�7��<�y�}����=`����XB�a��T e>ǌ��d%;r���}=}(|����@`�M�`��>��v��S<����o)v<�J��Y$p=2`o��[�=�pĽ[�N�n��^	=�I�<�T>�;��]���������/�|��%T�%��5��YS�H�=�%c>]�>��v���.�3g�=JP�"̌=����a>
Oڽ����š�;�>z��K�/��M\=;�1<����L�0���=q�v�:h��A9�;��G�k�*=&����>06�N&�=|m��-�%="���=<n���8��n��=�=�cp��\�>�Z>����_P��('>-e���Ǳ�<Ѵ<�>b>�+x=��>&���������<��	��Ɔ�e��=������4���˕۽9���f�<�>��߽ ��\>�[�=U�<���;�}=��5=��о���;\k�=�<���鹣�.=|�w<���7��=;�)���,�Rϝ;��$�<7r�<}�=�`�Q>��<E�5���&��9��6D(�ĉ��Z�<֦�D��ۊ=��9=� ��+����{H��w�I:V�C>�d>3���zý!?�=K/X�qbm>����按=�o@=(<>sTJ>�D���=��MY�:�"�=Ib=nx��탻���Q&�\�"̆�,u����q���D>d���e<�i#>�WD>&Ϊ=5�%>���=��
�w�μ�����A�������8>��>k����L|=��>�D8�˷=`R�==1�=�H�=4>@r�=xnI>�&��'�>̛?=5Ӗ=�J����t��3Y8�f@����=��=�����p�4��N�[��D��=p�>����nK=YH��mx޽�}�<Ŀ�=�u
=��>�a$>����Uv=��ǽ��/>#�-�o~�Cc2=���90���,�׽r�=�4�<�y��l���NM>x;�T�.�&=3���F�!<:}y>F��=�b��7='����>��+=�^��h�;K#=g��=�-G>�M�=�ke>��/� �=t��<Y���H��:R��³���b�<}��4a��u8p�x+<e=Ņ����ڷ�P˹�;��E�����T>���y������֚��T���<�ò�����c�6>�fV�7z��5�Մ�����ܼ�����D5���!��?>*@=$w���>�̫�F��=N�t�r�>w����;�1���x��9��]� =�B	=�����Ǽs�����>�e=�CI���>YЄ=���L۟=�мM�n=d��V�=�E�=0���t��|k��8����n�:?"��I����	�M��<i�>\+��H�=��<�?~=S�F=p1��S?�!�<��Ft½CU��&�ۥ=q�����L"B�ol
=�������@�'>a&=���=2Q�r�x��ޠ��<ƽ��=�=Wy�=�Sl��d�;�C�=&)���<�z�=�KR=�'>蚔=j��� �V��q���Z=7w�<�>%�K���!��ؽ/���KL=OA��9��=:�#>+����,��Qe�W���~i��I>&XW�N��=zJ>�r��`�=�τ��0���2�!������>ue�=R�k��>�4�=:��<� �=0 >��	�j�ֽ�=�</)��
���z���B���=�9@>es�7����H;d����M���=9����x�=IM>�e��tW#��jn>F�2=q&;c_��r��<��Q+<_�=�R��c6���=�
뽏X>"��<���=�ὂ���@Q���4>�|��'�=l�P=�3�=I��Ny=b�M2�-�=��Ӽ	NE�U�t��½_�+���2=�RD��H�>ԑ�<br�sL>B5�=����G>�Nu>!w=8;A�f��|��=_~�=P�       �y             ���>�*�>)�,?�*�>��>��L>�Q�>�h>GD?�p(??c�>�?��?aN?��>���>*�f>�#�>��>j�>       TM'>p�>�S��V���[�3>Ut�Й<RhM�`�]>�e��6v=�6�=1W'>6�=��K>��[>l���1�>`�]�L�>s
�-a�=ٲ<ލ�=J��:���� ���\={�=��+=v1�S�=kdt=O�P��u�=��=@g>A2w>��ѽS�<��=EkV=H�=Yw|>�=�Y����=E�=�ױ���;>�Pa�4,�=~�{�X*6>w��<��<,��=��>�k<K]�=K��/�һ4y��	�P��˼��[��X�^;6�: (�e��*�@���<��<�Ey�e���u>���<M�漃	~��~)>̄�<A���ZN^;��>ߡ$>��� 罓ľ=ĩ>D�;�)�|��;s��=�@3���7�D33>�b�=!��ߛ�o/�����=�JؽȯY��H=��<i��G_����v=*&=�Xa=P*:���9:�����<�˙���<K�7=�n��(�=:<�=V�=d�N���=�6>I�G��#�=62���5��3���zV��]M��>{D�=}��=a��*�˽��ͽP� q����B�-=��c���7=����I��=n��<=m�a6�=�[<=V&
�����h<G�=Q|�=���X,Լ5>�9�=[q�=.�8�->�Ǟ�7�����.>��>�,g�(;�<�1&��h�=k�+�4�F=hA�=-�>F7c�|Y�L�ӽ �>>����}��.=�	*=�I�������>>K�>4����'ӓ=�Ed���ͽ���뻼��f=e��1ƽ�g�=5V�=�gz��;�<��ټ>A�;A)Q>�G��9�<�_|=��X�c]"��U���u'>�T���d�=�s�=�;?>n�������
�^=-���*@
�^lF�
n����=���<*��==l>i�;�G
�<K_g=�bf���>�$>^����e���o�����H��tl=l��=q�>��?>뺒=aTe>AK=���G����;[>ң�; ���֒��b�=P���I=ҧ)>%�K>͗>�g'��"-�tĦ>��=�y�&��=6��=��=k��=;=f!�r�=ݐ���π=�H=�t�<"��=.���	�=�_�=?�5�<�5>�z@>aB2>[
۾/v.=m�9�5�=Z�*��y�=._x<�r���U�k̀=~��=��w���>�@o>`�>�t�U�1���|<��ؽ~��<��=.�콚���]H>��<o�,<�c�=m[�O�v���T<�{��[�Q���%�G���B���D�M�y����=��5���>.p�=*�=��*>�e<��o>
D>�^� ���	>�`��*>���X�Ѽذb=Hga=k��<>O�����B����ӽ�F=��vyt<,�/<e�&=G� >t=ϸ��W�2<QSH=-�J>�V�=�rߕ<RZ�Ƽ��P��½�� %>\o*���м'�=��e�	��=�m�>���=z
>f=(�=.�0=�Ř>3O��+�#�y�n�id>�k�V���0<�e�=��>����bP=�o=�=�UM��8>�Z�z��<�6�mu8��4�=Z����$>��=�V->^�����ѽ<1�<�D=�2P>�|�=�L������#�1ϼÓ,<"��=<�:�.�fǁ=�꡽�a�C�4=������~�k��'g��л����Ǣ=������;>C���s�=�>�Q�=8ä=�a�H�½h�>��ԽBB����7�����)�r!Y�+�}��-$�v X��㻿A+>b���\5���<&�� �;�~�=Z��==��=�N��	�;D��<��<2,�Np����J��=�Z*=m^+=��<:X�=j���g�[���!>[B�=><}�����<�~Q�H�@;�&��i�=�L�=�	�;��}�:a>_-���=A��=��6>ua= k�<L��=h�4�L*�a8�>�G��c<ڽVdн��=�+���.ým��<bP�>�{�<;�=�������=�$<ۀ>�T�<��>��D����ی\=�.�=�G��ü,P%���%>1�	=�T����;m�=��=�!����̽O`�<բ.=^Qx>5I�<��<¥j��S�=Џ�<��	>|������w<w&6>"Tڼ��P>�\�=��>0�=�js�#�=���=��&�4F�Ŝq;�<���==R׼�y>\Y�=mS�;���HY���a<�����=��(�~o+���8��`>��=�>�t >�ʃ�������a< s3� �=��<�T1=�L���K9=8��<�<:<.9=����@,>��μ��-���=��M=뙣�#i	�&��K 
�!=���<N��=U蹾�=kh���1v�9Ó�=X�E���P>c�K�6V-�|���͐=Nͯ=���=r��E=���=�'j��|�=V\���xL>B� ��BT;�6.<xC�:-">ԢY<�t�>H>:�D<)��<n*=��:���&>덽���<Gb�#�<�Op<Mֆ>��7������G����Q>PZ�Sc��="���=�>P�=�����=�z;>Vj���]��IXJ��Խ�]F>�ֽ�Z�n$#>��>���\�>">̶+<ҍ�����T�<j�k>��=�D�=��=7�.>�
��G�K=�Y�>jx>��Ƌ˼}�>��F=�&�`xs=�,>��i<���=��>���R#��D�=h��d�f<5YK��H�>�>l�>o�->Ō���w>��>ܒ)�oҽ��kr>J��=l�>�D�������=\��\)���>��>��=�8A>�G��"�>[%~>�p7>.覾A��<ٻ>CI>�\>��J�q-�<�fg��פ>�&>m8l>a�m=q��H�=Ƭ!>J������!�=n>ɚ�="��LD�C��=���鳲=�=���˅���
�ZY�_�>�� �6h�B]�<�A>�!����\>��۫��!>�c轌�C>��>j|���*|���>��=\�;�%�b>�eO>'ĥ=���<̶����0<{��={Ḽm2	��>�7��]�ɵ;>G�>D>�2R���S��<�h˽4�eѦ=�O�Wg��r��ᙾ��.<����|G����=P���=�烾�`�>;�=���=;��̘��H�L��=߆>XX�����T~=
A;O�L>p���sռ�u>'�)>�Ҽe��М�PP�=����-�%�5н�tK=#Y<�>�6q>$3��RM�;<i=�}z�P�w=�@W�w���1>	 �=���=y
q�o3�=ͭͽ���=�D>/5�=v�
>���<3X���=2bS>�ѐ>��ζ5v>��:����7�cj>Qm&���(>!�B<���>-e�[H=��`>�{e>X>=�c<>kd�=�7>bυ=��k�2��=J3�=p���뽓���m��O�<�5�P.Լ+����&=���=tNϼ�2���ԽJ�=��=u�p��-'���ռY�?��X�<�E=%\�ɍ��Y%���W*�=�c�Jz[=�,>=�[M=S�=��7>�a�>�*�<���dN�=�Zl>>I=c�.�r�¼ ��=�4�=r�<�x=z�;==Tż�*=w�=|�p�o8�<�6�=��=ʵ�>��<�	=�>j��V=ϕ�&4��q\�=w`G���͵�=-6(>X��;���=`4=�D���*+=��˼���=��>jh>��<�!*>���=D>ۅ3���=���=Yr�=Jh�=3I ��7=s�>��4=p)\�]����;If�=�~��|�=�O�=�z�;%�L<y>k9��gc��h>�S�`C�<���=�8�i�k��=l��< }G>.�)������=��>>R�<i�ü-=2;>:���<�P��|��<��D���b=Յ�=~s�`hy=vA�<��=]�12�WO=Ӵ�=F�=���<
�ýQ��>����9\�㒨<��.=
�>-i�=
�>1�����K��=�>�+h=���=���Q۽ѓ=,>y���5k=+�$>L�1>ֈ�8d!�-ܽ�](=ð���K�i� >�nϽ�߶<(*��� >uD��ʺ=W��mZ>`�E�Б9=;�F=4�r=_#���.>S�F�:'��
Hý��*>��=_z%���%����<���oޅ=F4�=^B@�|%9�t?��J��<u?��߼^�==���<%>�mi�=���hK�oN�*��=�6�����Ko��>�Ͻ,b<`A���Y��T�=�JK��ݽ�@�x���8�+x*���
���=�b��U���󟼴�=�����S�;�,�_ ��wQ>��3�鼽6H�*쥽Z�D=x� �s:a��>L��K��r� ?���g���9�����X�=|
�j@�=�_z��mԽ��;�������<��A�9&�����`/>����І	��-�G>Ca�����=H��<��p���<Z�ȽC4W<��<��w=�f���=j��;�ؽQ&���Q�O�=i��5�]v}����<$���۽_�=3u@�$nѽ��N=s0>y����=�4G=�}.�9������>O����o��W������ =�1+�
HC=�&�=0��<,�=�<Ϧ��I��=���<��F=&Qs</�>���=4�^=~�%:]~���&]>�}�=�a��i2��D1q>���C�S=C^>��1��l��,ڽ����\"������=ڨ�=%�6=���<L~ʽ�����>��)<E���0h�/�=���=�p��\���<30>�V�Ѡ�����=-Υ�ӂ>g�z=��="��<+�<�A�=-�U>��̽`��B0=�n>�
�?#��ŵ=���=��G�;�l�=�V�=��<�����>�7Q=�N�\c�@3��W;>d�I=  �@�=�κ=��Z|�'�;f~>�:�<��<U]�*�!=\:�<��=ۯ���.>pF���`� λ�-�>��x�lݼiW=Sjw>7Ya���.=�?G<P��6ֆ=��M���B=�>�[�=�.��#>��=7�?�����<���xx���1>��=�VW=�O��F׈<2���H��p�>v6�=�v�=;8ļ�9�=2�<����,�=���=J�ѽ�aټ$�=ۥ���tE����=x��=	#p=�����k<ǈ<�Υ=�H�ʜ*��0.>�+�=V��=:��=�Y>X��0��;��D=1p��fB�A�����=J
ǽdk�=�н.&�=6�;RMC>��^�d��<��k�s�=
�[��5� ����[�=�6��c��<��>�A
���`���B��;#>`$��߄�<],�0�w=������=L��<��B��E���m3>N��>�Z�ޤ<f�=Q8y��Vi��;��˼��]H=Үӻ�'��8>$��;>3>,L�=��jSf>^��=�N�T=�`g>��J�N�W=�W>W�=з>��ݼ$��<ܢ?�=߳��3�m�b��=��̽8�~����=��=KS��ϋ�?��<�,��W%�dՋ;�����ܩ�X��Ȼ������f!c��ؔ=�"m����+�A=I��=����=�
�J��������=CS�=j�{>�����e=�,��G��<,�f��=����$>|���X$=�U%�t�;�V�=Ӗ=Đ �ph=���>r&��w�=��=���;+ƽ|K�=�">-\F=�a�=���=z��<W*$>����������K=�L�=�����>ѧO���H=g��=Zd��_�=�{� �=\`#�3�X=L�
��=0�ǽ��=k�/ӻbǣ<�J��z8��+蝻0���1ɉ=��<�x=ⲽ�O�=\��<��>����Հ=��=��=�����@���\�=ζ�=ej��	>ہ<2�<3�C=�.��!=���3����0<�a�<����]=+1�=��ܼ�^��Z��
�$���=������a�0B�=���=/�c�:ے�<���>'�=a����	�=�V~=s�6� '��?�@=Y�!>�ʼ���-?>:g�=��u:��-<�#>AW	=����S< ���=�\�5=us�	�F=�{��Z�=�N�=�������>�,�]�2��ս�;���?==K=�6��+'�I�
���Ƚ�.�������<l����1S��:�=8�=/S9>#q?>=�=ͱC�'D <s�f>�a>����Nv<?2M��~�='@���c�@X9�p4�=�[��D7�����T�=?=bVF>�v<�f���I
>��h���='#>�>>�hL��W�=5�=�If=M�=a�=�;'�T�L�a$<6�,=wͫ�
�>����e�=�������B��Ϙ>� ��1=�W��6��6�@�-�����K��s�{\��3�i>1Rk��m��������_=�Gq;�>��A+�/�$=�J={�����=|Zн���н��+]>8�}�p���������9*�����o�pd�=��)=���|, ���
����WκT(�<�=�[�׽i�{��=�C/��/f=�!�:�nm�q��������6�<��N=�φ��\�3`��7a�s\���-��l�5>�XN>+��=�*�>#���k=\ܛ=���>��=Ƶ�=,-X=��>��j����<���<�$ܽ���R�D=�޽�>��=���%X>2�R>y>�h%��tx!�7��A����>Kk�_�<`�<ÂW��0�胊�����K3ռ�j<��T.=h������>pKh�Vt��U�ZE#>�[�=��=d}��L=�=��
>�G	�<^�E��=���;N���D�,
H�*L0=}�2�H�н3G����?���E�����)�>]���;)�UF�<ȁw��Z��c(̻��
<~8=��F�bF��.���j�H3'>�x'>ȦO�Ӻ�<���=:�<e~�<qƽ0R�=�Uz��==��=ly�=�1����<�U��=�-��3Ӽ�W&=��>Si�=1[>6��>�~=��<?�9c}��5�=��K�����[�>��=�h>�	����+�r��;zbB�(�9��vg=�����f���⓾�$	��U=�=���w�;X��=�gϽ]��d�¼��':�fJ=y�=�$>�#�=��Q>�Ɏ�gsq�O�2��=�t=W��=}=��_�׽)��#�TL>�3>y�����˽%��=�c�>n+�=j���r�\�>��>�j��W=`4>yU��4�>`H=����#>�І>@��=��=������=T� >>@r<�Z潘\�a =.Rw�	i%�����V>���<�8T>���ّ��9�<vp>-���>���=��ý7�=����>¸�T=����Gd�>0V@>���=ڹ�=�2�<tr��=gg�<SZ+>�y0��M�:g �Z~J� ,�����=B<>S7�=J�}=�	=�>I=%��F�H>斁<<P-=c�">��J�N�>� ��z\>���=:�Q=ق���@>5�+=���=6y=��*>&Z�=}�w=��˽��U>��f=��C=��B��A��B�<[�=���=p�v=���+=L�s<2=^�n��|o4=���=9��<M��=�Oμ�
�<���=+�Q�<=Fa�=ƀ����=��_� �=W�!=���j�=�`=DC�>:�>���=�F�o�Z=�kT=�w�=I>���=�OU=3�<>��Z>�d1���e>x1>a���̃��# >����'&�=�=��V=��V>��<g��$R��=�tj=-?�=Xk|�rs|=�P�=���Q�ļP-=��=��1>��=���=G��Sxƽ���=`��=�~9>f9|=Q3#>q2�oq[>�j�c'�= ���0E=۽5Y����ͽv([�Kp>�>���<��ؼ�}ڼ'wl<k�6��U�%�>�� >�+U��dR� &>���=���kXt��m����(=�`p�U�k�4;p��v����)����~��;󑮾1����l�w�V�D�����==ཋ=����67�=�#���zS�Ր���^=��Ľ�C��x�=,�=�����=4ӂ<�ތ���@�N=���H�>�6Y���=Dj<>K���*�����=5Ͻ�6O>�fr��lM>��:� �����y�,<���=>2k}�ɐʾ�僾�Y�xFW�K߭��押E@�����<����V-�=C��>�	o=��.>�%w���m>���=�>�-�=���=_.���w���:0=�O��m���S������d˽� P=��̻���>�R�>�>U��>P���Xۼp/=U�=M�>�x����=[x\��b����R����=~�>)���Ĵ��w�>��y>SFݽE���a>����@��xS�'�=��=��3=�m��l\�=vc�����p½ن�<�2 >�!��ň׽��=?T�=�}⼏`�=D�n>�=���o��I>��O>��<`#���V���<��!��LI=��˽�`=�k���;�9�P=4�=�}D�v�����=lڼ܉q=}R�=\>4�/:�w����7���V��Fý� ���`�>O}���X��?���=�M�z&>[�� ��$	��R��	[�����򨲽賵=�4�v�v�P�=� O�+������V)�Y�d��
p78�=��<�R��G>A�I�.X��b�=a[��ʩ;�8� =���%���bd</�e��tK�B+�*MT<1W�=�h��/�l���;�_��<���>ٚ�*6=�!�=A�?��=��e<6�ͽyf�<V3+�j�h�\e:��ϽV&��n�߲�v�����{��=ڏ����]�W���B[�;.�4��~f>I������*�5�ʽ�h��':"�������>L����.��ý}�>��F=��<g�����>/�_��<�x����
��G���m滜t���s�{+�d���#(��GC<�O�I���S'U�P(�=Ɂ{�uv�<���Kғ=)*1�g���.�;�l>�M.�����AuH<>�=��?�=��B=0c>-�%���R���<�A��_��5�LJ���-��@���}�Ϗ�;a;">�e��;�	1�'��=����ܕ���i=cZ��_���Ť$�^b���<y�>CY>�+>	��>)C=���=���=).�>M��=��(>>;��v�F>I1��幽Z/����=�|J�v��=>� ���=4�>V��=W�>�!>��u;st
=��5�ć����=��.�:Ck=���=KX���ĺ��׼���<���=����l���4��7�>򍂽ϕp��_�=��޻��=x���/o��2>U��=��>`L�=j�ü��=
��Q����P>R$��Y���~��@�ț>�^<} �=Js,>����d�=ȝ���R> ��<�$�=0����K=�7>TH����_Š=�^>x�Q�{��O��<Mc�= kd��Z�o͹��z�<��=��:��8�A��=�>5x�=�\&��fj� 7��4?�<<�=���;k0D��ۦ��?��*>��=�5½����ʽ������=]��LL��O�.�W�~=D�<	e)��z�5}�xI���?��	�=�B>�<�<�,�<��<.I>��U<�W$�8?n�_�d>���=��;��!���>=�����l=�gD��H�>�,=������'<_Η=�}M=g�=���>��;Z�ս¼q��?t��z�=r�b��G=����>aȽ<%��Om�<b6>|��9�i�=��=��<�����d�= r����_��w>�L�� �>��Ľt[���;��y>h��OO�����=v���W	���=q�;
��=�UP���/<���=���=S�ž�$���^>nn���T�s���=X��;�G�=�F����=�j�ѧJ<ռ=	�>. �>����EY�e�&>�	=}L^>�ah<V���l�<K�� VA� �>	>嶃���b����=���<ï��*?=��=��l=�[=�^=9��M���� >��>μ�=TܽɆ
��&ľj�>�6�c@�: i�<Yj-��.��ޑ1=��&��(�@�'��x���"�<��)>++<�S�=��>�6�됱=���=�>T=��=2�>���=��r��ϰ��쉽7�>��h=aQ�=�3>J�>��(>��+;a�R�����@=$�'���2�h�{=��?k��)7��KV������,��������Cݻ�X�=u߂�����>�>��.��|��=_��k�>y�$��9��.l=%�$>�Խ,[������8�M>�k��" �gdI�gF�u�1�0j�=�&�]ӽ��G�h�ͽ.�ƽo��?�=*�>�跽*��X-��$�彼"`�J���M	=e\�ƚB�N3�=�E=3�=��4>W(�=]��=��`>6��=y�[=����z�>0L0>���=��n�m]/�Ax��&�=M�=�����Ge�9�M=2�!=��=��=�q�>��#>V�X>��<�V��$��s�= y_�}5c=��=;�=U�=�7���O��y�<�(�=��$=�+�+^>셤=��=i��=���8Q����<Ŷ�=H�e>�G>�e�=(���u���&<>��;�N`>��=Л�=���Y*�=Y�»�����=��<��1=/(�͚�=�t6>/x$=��>b��F۬=��=#' �X_>�)�>$���x�����	�V��<R.�["��-�<}�A� `)>X}��W";�S=c�K=��G���=����h�R=��R>T��ż�fh<���:��=P�Y��?��gK�>��U<�|�)�i�-��->�ů�Q*���M�?>��:��S̽VI,���>��f=-ˮ������=�I�j�E>�����^�t�����>O��=�S@;�T�=�C�p�ǽ�O�>n�=��媖��+�Dt�`by=Zb>�T=o׭��rq=+l1=:|��-K����<,
���G=��ܽ(�=&4	�wP=\�5>��d>f]��Z�=��W=��=��R;@��=Ƹ�=x��L�n�lD彖� >��ѿi<�D�]	<Y{���"�;�ާ���=,".>��=�G�=x���%�&��E8�LV,=W�̽�V�����^X���'��I$�#����=NJC�͈�>��4=) S=]����Ϋ�(��7�j<{�<�N��/�t=�a$���:>�|̽�g>xlѽo�.<ʫ=��>V|k��.��L3'���=׃ɻ 8�=v@���(�>�{�rA�8�μ)���N��J�ɽ$Ƚ����:�)5�Y�6���S<G@W���^�xz�J <0ӡ�?Oe:H#+=x�(=k�罿���E�9����=�>��2�b��_�>�P���?>����W�J>��$=�^>�=1>��`M�f�=�,�<�@�*al���e>�.�=$[�<֩=�>��M>:ʽ>��<����͑8>�ވ�����R!>�>:>���<��1>8���>X�ѽۘ}��L&��<�=ߌ!�������V>�Bǽ�X{=sC��0D>D<�>.��;ïs>)� ��얽3�>>��=EAH>���=�]�<��l�Ly=6�D=�wν�i>1��m�>�<�VZ����=�p@>�&м�C<3,;>���ȿ�Z�=#4�p}�:�j�=;�>��)���A��}���g�<��q=O���v�=i��=�E2>�Mw���	>���<?׃=������ =/�*>�&>��K����>�F:>a�4�	�=�w!=�2�Cŝ��=�?�<ݭF>]s ���+>�V>Οd=����ý����V��m�>�|�<����>��=� y�$@>3%L>�%K>@q��"�=Pj�=�p �A)g��2�=�����=5���7$�^��=������#���<�+ �E+=0������&�H<a��亣=v�=&U⽷˒������=�����A>h5Ⱦ�hC=t���D��=ڦ��Rm&> 2���p��ጽ��4�׽�P�t�K=��
���;�M��uP��!��Vv�=Mg���M�;hZɼ��}@��_<�,����h<��Y| �1��;�}z����i_�(�1�o�=���=}C�6��=�t��at��n=O|�=jY~=)Lؼ�4��bB =���� Y=t4/�ewg��(ԽsQ�X׽9�>�6>a��=�>�=0��1�>yOн��=�+t�鍣�F]����B��=V�=ǧd<��y<e�A�6r">e��=�'Ծ@���f;�u<���b��F_�+H�O����6���л�^=_ԑ��x��j����D{>���=V׽sa���O߽�KԽ�����<U���>{:���LJ��(-�l< �hR�Қƽ�ef��z$�P��l��9��Ye�?T?����=[^���>:>1G��M	��>��=�Dl=G��=��>�oA<\7Ѽt���{:=�_�=܈�=��i=Ug>�ү=�%=T��ef<����[�=��Q97=���3�g<+@%��l=��P=)�= �>#;>�>6=6�=�7"<Vp�<�t�aV=�.�=
(>���=6�=�4	>M�=�����=f��=o��=��<�Һ����PZ�"t`=8�^�j������:�S=<M�=(���u�ʶ�=��=�h=_k=>W�;��=D;ǽ"�=q��<з(=�@
��I$�l�;�:b>�K�=���t ޽W�=r=��B�N��<|ѽ)�o=NHR��֪=i�=��4��w=n1z�&�?�����M��)>5��)�o=�u=�9~��mI>����J'-����I=k7ؽF2>Љ�><�>�2�^i�=�e]�ų���u�����<����|V��!쌾���<W�=���=H�5�M�0'[>��/>�}�[���ɂ�,��=ݓ��"ެ����|�>��P>�qL>L���9���=�ט>�TE=MDx���5��q�!�n���=0�8>�1���������t6����J����_2��v<�ou��ٽ��)��慽3�ؽō�IɻY>+<p��{>�!��Jel���7������5)���X=��]=�(<���<�:2������:�={L��{����p�>�o�<w,��>k��Q4Q>3P;9#�ɽ?���~�=Y&���pb<���<�<>��3�=�9�94�@��xȽ���H^m=�:H<������<&���N��h����~�<[ϑ�Dȭ<B3!<��Q�l<4Ek=�V��c�=sp�L0�=�o<y+M��r�n��<ػ����<�|�=�{���Wм�iüv�۽�Z��Z�<��ս����F�B>�J�I�S;n�=�,�=H�Z��ؤ�1��=H� >"��>��=�F<�����##Q�\�ѽ�֓=0V��$X�=�m<���&>[^@� ���M25=�Ľ���ˇ�4x5�G�O>zؿ=�{b>��<�׊ >=��=C%���ؽ	�=@�P�F��=��n�=µ�=��=�^<_����7�����#YP=��ȼ,�}=�ꎽm �=�0=ib=i-�<�/ݼ�i=�����퐽8i�=t�����=M��w<����<@/D>*�i���Z�
.�<��μklK>=z�5~��䇽xu]>�O3����=�����=J��Vp>}:����:��>��=_� ��`M;���?������ ӽ���}>��r�1�L=(�5<0K=L��==��=�}~���>w��=�^�;=�}=�����=1��� �=�EѼ1�=D��'2�g�e=�+�=�d�;,��v�<քo=�嫽01*�:� =��u����ϣ��g�=�x���k����>`�`��G	<iF�=�e�<F��=
&*=&L�{|:>#�/<�\"�1D=�^=|c�'
�=�x�T����2=��<*���8�@>�x�uɋ=F檽���6��=)��W5=f�����=�B0��N�V\��������<R����^;�o��{K�=����>���U"=K��=��6=)"�=&�8��ؒ��7=HP����a=��-�f�;k��>�׾�k��k����>�����=��h��u�N
��Ǣ>E����<�>9�.�R:��]=w��>"��``�<��
�d�=��ǻ�\�4�ѻ�%>'b;9�U=H>�~����6�3>�1��K=̤��4B>i4�=��=�oG=�Bz��ƻ=<�>4���=F����T>��=V&>ͮ%��er>�\=��:��}�2=e��A	��^&>˞=�\�<iV�/�K��T��!\f>����Ǻg=���M�f==��=��F=߇/<�ҳ=N/x���<��d�S�	
>D0�=E�>���=H2���=T���<���ma>�͏�Q��=���=Y�>�i�s+>M}�<�"���dU>�{����g=f��=xB�<p�ҽ��ɼJ���?�=Gb�=]Ļ��=lż%^�Ք�=8
>��3>���;�o��aj���	8����a@=x��=z��=��>��;M6���_E=�G�=�{1�񚣽`�>�8S�-½�5��W�= �>��=�a@���{Iy=�/<%u����=��o���<���<r%��vp�S� l�&q�<mɲ=��;<���<Ǥ��22=$y;�dcx���ϼ}��E�E=�T����:/>��j=a�j�s��LD> @�=��X=��:��h����=�ێ��g��;�+P���/=6��8%>u��<5���Х�<?��=�~�=����=U{b>a!G�8��=ୁ=B_{�D"����ʽ*9��ƞ��+��J��L���M=`��=�q�A�=X��|��=��9�] ý��,�/�>���������<Y�>pΝ����=Nb�-�=KrX>�p�=kK�=A⛽�&=(�$=FA>޴6�gK�=������>#0=�:���=�ݝ=�y]>+�>�a=�Z=>�>���;�;s;e��=[8���ŻK=�����N�>Q��W��cd�<���=?�<����^���qo<cf=��m��Z�=M�=�F��;v꼬���Ng�=o�s��Ɖ<7=-��Ζ���3<r�8�	�w����s+��f���M�=�'�=b��9��1<�I�=��˼@E$>�=S�=��������S�=�W,=/���+�@=D�=̝O=�K�c�='* >�
��H+��^`�0��>��=H�w=$j=͚�<�%:�o�����=_i���
>;��<X#׻�*�"���W�v����=��H�֍R��%>~��=���=g#K��\>k$G>}�]=<�;=V�x��<>���<j%м~�9LEɽj����t�[>2zV<��<=�4=����$�3^]=!t��P��˼�9��=&�4>��k|���F���-�=c��z�=o��=C,��V�JF��d=�Y=��<Iwۼ�>N��f�=>�d�������� �=�c�Hd�:E�=3[��:����?������X3�=�hV>n�������TI��  =+hf�xT�������U2�.Ow<�=X�G���=)V�=���<����D�Y��7�=��=�*��յ��J񽯊���1��Eϼ�>>��=�,';<݂�d��'Fp>'!/�#/(�|"�:/��;�-\<���<Zf�=�ь>l�=�,=,�tO>/N>d��=!�>�	�<QRO��@�<ޜ�>a�=>�<��D`<�	�=md�n�N�؝��LD�>���`�l=xg=4_!>���=P��=��˽F��=N*K�i�N>���؉>n�>�=����
>!N2=��=<�
��Ո��Q�=IU��#��s��=�=����=����16-��}����=�\��h�B>�i���X��h>XL=.�G>D#�J��=b%�e�<?J���b�\�=�Ҋ=�+	>@G<@>���=�4�=�\b=������$��=�Dལ`>����S�=s�vZ�=�'�==��=a뽃�����<�O��6��F<*rܽ��A<��L<�	=���=��=!�=}�=!r)�ܰ�����=O�;���=a���ϑ>� d�Y��=��'=��>;ݽt��`>�⮽��V>$y��~�>J6ȽY>��!�ɒX=�����U>��<��<)�>����m)�=�����_<�뒽��=�i���w=u��<:�9>�(�p�ֽ��=(�n���V=S�>&Z<C�=@t���	>��<rr=^�(<R�-<>~��=,�>�O�=zF-��*�<�"c�P)H���>�����V�=�!>�f?=$�ʽOW'���<��b���d=X���P�.4@�]u2=b���_y;�O��[#��^��gtZ�����[@<A+���죾�)*>d�a�ӽ��>�# =�K;V\>����ĕ;�i����;���=�І>�/2�mk��[X�=�$�=h��<��=��9=%�@��X�F��=��J<�ؽV���Ƃ:�rD�U*E�Y�=�	Q��l�:�M�e�r�$��� =6�=�߽tٍ�vܽ=��<�%ڽ�ȕ��.=hYo��t���&���U=P�����Z>K�_�������`�㰀=�2�=���<�(*>>v��R�;տ&��>��	��p;���<W�Q�b��?�:��,��<h-_=�Fd����>��=ӄ��*Q�'͔>�D���=>>�!�K�e=����jD`��c�8�=�{�5>v�ٽN+ >��ϼ�41�b\��r�m<D>n=6��=�
b> ��<c�=�r��׃�>_��=KG�<�;�_䁽�`���j<`/½�<�=n3�������nռ�Տ=�'><�
��/>��=+]�׬��)q4>��=b��K��� >��=#R<�{=�U�=���=�C�������%弚��;�	>��>9�=9�/����/6>z󺽪�o�I�������"�=���j=�ur�}��=窼=HZ=�F���E= ��w���V��==�/�=[x�<�6>	} �N2�A��='!̽)l����;�e8��Y�=�t��ԉ%�y&��7:l>	������wp�<��M���'�u�(>��׽�;�=XW���]>L����	=L׍=Ɨ}=���=�ƛ�Cg�<rB>�~�=��=��=��=#��̽u>K���_�.=�%>?C>��<��7=�j=`�>�=��Y=��Z>��۽b��=��\�=��=򆼑~�<�h�����;Ԗ�=�=]�=�7^=��F>��@>\�=ph>�l@>��ܽ��>>N�=b>�=s�޽q�>���=��>�E�� ��|�=(]���/=j��=]��;ћ=�$>�=ɉ�;����=��;�C���޲=w]�=���=��μr�>�"�<��=F��=��8>�ϽY�=�<(<C�=�
9�I��=6��<T�;�Z  =��=���,�=�V����Y��w�=�<�Y��λBd޼]�G<�2>��k��kR�{�<��~��Y�=�g>x�>�%�=���䆄�㈒</=)?Z�3o�=B�=E�T�=M�S����-�Y=�5[<��)�S�k==�ݽr�>U�&= ��=+�ʽ�mX�eE<n��<̔>,���v�ܽb�h�kf��������� ��z���	��F��!1>�e����>q�:>'��#>C�V;��#��o��>?��U�=��=�����<��>l\�=u%��%Z[;�4�=Ѽ�=Qܹ�ͽ.><��=r�=�ƽf�$����='��Js0=�%]�4d'=T�0=?/�=�xѼ!$�=H?'��Y�=8ǔ=�����r��ޭ��>k��3���E��=[��=�^<�]>�����͡=�Q�<�9=k�=�1R�J
=B�?=@p>�x8='��>#g�=8�
>���R[�=-e����="\�PR=���ܺ߼K��<s��m��"V>�ֆ=d�=�>�=Om�=)(� �>�i)�S��=�~=�S�=�\=�[)��~�=�i�=��=|=�y>��-���>�O>�?�=D��=y÷=y�>8C�=r+>�o�=bF/>�g4>��>�=��`=�t�=�g>kq�0��<���=/��=��u�FG�=6~�����=د��r=�o>5Y����<07�=,3���y�'<��ǻc�C=�̓��3�~I:�ɂ=�Qo=���=�8�;�m�=�=Ė�@1�=oV���;���W�=��=>�d;>]��="h�(z =����=���;y�=ѾF<��*>*�<di�=TܼFo0��.��M>�К;�A;>�98=TO�w��;<-̽�8~>_��=�$S����=�+B=�`��`z��L=��=�f���{}�AV->D�L=�fz<<N�`ԍ=�	̽��b�����]i�`$�=�ɘ=e�c����<�dg >Yg�=�|K=wC��غ�b���m���A���HD��U�=2:�����>�<M�>�ꩾwٽ�p������0M���$>O䶽˫��]NK��e����;��G>��7����:j��=���=�>$��&O��D>Am4>�Eg�gӒ�+�.>��<���b(���'	>�;fD���½^�W��ʼij9��p½�\��ŀ�=D��=>'N�Rʽ�������П��)�=��=R�z��_�;0>}��=./4�??~�fr=�͎=b��=�����=7c8����E��;�>=rN=H&�c*�&�B�H��.=>�*|<K&���@�{�=M��=S�����=���=�i>C��<�e��/.��z��ㅼ��#������]N�=4 J>]��<�1>~W>��=��=�U9>n��<H>�)<q�/��;��2>m����{��ÿ==Ѧ=!�.�z�� ��=y�>JG���@�<b����<�i�=���=_�>f�=�w�8&=�ż�>�I��l=N�i���"��p���=3*>�2��>s���<�u�]��=@sI�z��=!�>�2Y>c�=e�=J�9=G�+�2��=q��ߟ�����=6��=�ۤ��\e�I��<A�a��� ����"��ou5�1}|����=�[>�<'�(=T���[6=­�=�>�E >��=�[�=k̏��6s=��W�B�ս�v�<YS���J>�Žs��<{��=������;Z'�=�x��F6�-=о=!>�+�=1S0;4!�=6m=���=u5�;�!���>�)f�2Y���Jܾ~�e��y�=+�2=õ��&b��#}���e��{���4:{�>P�>��:�О=����=�>��=DS��N=�&ǽ�d�=��1;���=KI�.�3> �v<�=�sٽ[>>Њ�MӼ왆�hw�w���y�h�xR���>\�s=�i���6>U"t������c�;\�����=��wU�<�?=>��~=ױE��=�=4r�>!=8���5��5A=����Jq >�P=�9�� �&>�b��u��=|�Q�aĪ����=�m9�T�=�E�=z�>h!�v]=d=���F���ͼ#F���ҽ�x��+��
�=R����=I�!�U��<��M=��޼pJ���o8��7���>n8�<�����W�=���=��<����F�,��Þ�%�8��F�
��ǉ>>1s�%���ݺ�(>�]?��~�Ծ<���=%���op�j����Iy=&>� 8=��f��\�=�%<[E>�sf=AO�����I9$>B��;��=l�N=������=�u��=(x�=Rj��`�<)>sG�=�%)=�� =��>�>b��PJ�<�/����^��<�q�=��=.]>!�=ǭ�=��=e0���m=��>%�սj�>Ç�����^�׽�o"=�&�d�"=�i:�gR<�/*>��=^ʽa��=�������=
�~<c`L=�2��z>R���[��=N���>7+н(��=r�>�_>�,�=!��=���WB>��=��>�<]��=�|&=�]�=${F�dD<����#0=D
d�����L�����'>Un>��=�����>�#���>�uB=_���p
>w2�=]��<m��;�4�=���2�C>ҭ�<b�7�c2>���=���J7O��nJ>A~��7ò�~�2��t�:ɥ�=���<Tc���C��#6>��e=���P>i5�=�H����=���=�W���d�<�>o->Վq<\����;���=���m��&�j�Ȟl=�t&>b�a=������=ѿ#>��G�h�=�w�=�pN�!�J�y�<>h��aY=q�q�?�<��c���>�Pk�J.p��9�=rY>o�:t��=�S��'�����@���$O��C�i���N�>$X)� (�+,n=�	����=Z�=���=���N�u=kT�=���=�>�pt�T�� �V>Z��<@       攩:<���3$>�ܩ�+�����2�����<�dT=��=�d7=�͓�є>�%���ͼ��:�QI�;ET�������">�cZ>��_�*>�=ͅ�[T����&>��l�V�<]@ >�����F=2����O=��z��$���:>���������p��$���/��;% 5=3Z=$3=�g=�J>8!V=�3�;]dK>+�{=֡ӽ��=v�=�
�=�h=Hd�=<Z��m��=��=�Ɨ=;�1=�a�=Y<�       K�ܽ)A�=��@=)�>���=�#��>�^��E�>��=��=�w�Y>mn��ϸ�Ng��C��:S���i�a�m���۽�.�=